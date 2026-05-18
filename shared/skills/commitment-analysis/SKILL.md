---
name: commitment-analysis
description: >
  Run a Commitment Analysis for the user — savings rate, coverage rate, realized
  savings (RI and Savings Plans), and forward-looking commitment burndown. Trigger
  when the user asks about commitment performance, savings rates, coverage, RI/SP
  savings, commitment expiry, or burndown. Also trigger for: "how are my commitments
  doing", "what is my savings rate", "show me commitment coverage", "when do my
  reservations expire".
---

# Commitment Analysis

This skill produces a structured analysis across three domains:

1. **Savings Performance** — savings rate and coverage rate trends by product category
2. **Realized Savings** — total dollar savings from Reserved Instances and Savings Plans
3. **Commitment Burndown** — forward-looking view of when current commitments expire

---

## Step 0 — Discover datasets

Call `list_datasets`. Match the results to these three datasets by name or description:

| Logical name | Matches dataset named… |
|---|---|
| `cm_analysis` | "Commitment Management Analysis" |
| `savings_realizations` | "Savings Realizations" |
| `burndown` | "Commitment Burndown" |

If fewer than three are present, proceed with what is available and note the gap.
Call `describe_dataset` for each matched dataset before querying — never assume field IDs.

---

## Step 1 — Savings Performance (cm_analysis dataset)

**Business meaning:** How efficiently are commitments translating into savings, and what
fraction of eligible usage is covered by commitments?

### Chart A — Effective Savings Rate over time by product category

```
selection:
  dimensions: [usage_day, product_category]
  measures:   [discounted_effective_savings_rate]
filters:
  usage_day: { gte: <start_of_trailing_30_days>, lt: <today> }
order_by: [{ field: usage_day, direction: asc }]
```

### Chart B — Commitment Coverage Rate over time by product category

```
selection:
  dimensions: [usage_day, product_category]
  measures:   [discounted_commitment_coverage_rate]
filters:
  usage_day: { gte: <start_of_trailing_30_days>, lt: <today> }
order_by: [{ field: usage_day, direction: asc }]
```

**Summarize as:** "Over the past 30 days, your effective savings rate was X% on average
across [top categories]. Commitment coverage reached Y% for [category], meaning that
fraction of eligible usage was served by commitments rather than on-demand pricing."

**Watch for:** Coverage rate trending down while savings rate holds — signals new
uncovered usage. Coverage rate high but savings rate low — commitment pricing may not
be competitive for that category.

---

## Step 2 — Realized Savings (savings_realizations dataset)

**Business meaning:** Actual dollars saved through RI and Savings Plans commitments,
net of any program fees.

### Chart C — Monthly savings trend by commitment type

```
selection:
  dimensions: [usage_month, commitment_type]
  measures:   [total_savings]
filters:
  usage_month: { gte: <start_of_trailing_3_months>, lt: <current_month_start> }
order_by: [{ field: usage_month, direction: asc }]
```

### Chart D — Total RI savings (aggregate scalar)

```
selection:
  dimensions: []
  measures:   [total_savings]
filters:
  usage_date:      { gte: <start_of_trailing_3_months>, lt: <current_month_start> }
  commitment_type: ["Reserved Instance"]
order_by: [{ field: total_savings, direction: desc }]
```

### Chart E — Total Savings Plan savings (aggregate scalar)

```
selection:
  dimensions: []
  measures:   [total_savings]
filters:
  usage_date:      { gte: <start_of_trailing_3_months>, lt: <current_month_start> }
  commitment_type: ["Savings Plans"]
order_by: [{ field: total_savings, direction: desc }]
```

**Summarize as:** "In the past 3 months you saved $X through Reserved Instances and $Y
through Savings Plans, for a combined $Z. [Month] was your strongest month at $W saved."

**Key fields and their business names:**

| Field id | Tell the user |
|---|---|
| `total_savings` | Total savings |
| `net_savings` | Net savings (after fees) |
| `sharesave_fee` | nOps program fee |
| `net_savings_percent` | Net savings rate |
| `annualized_net_savings` | Annualized net savings |

Never surface field ids, table names, or fee line-item internals directly.
If `net_savings` is available, prefer it over `total_savings` for headline figures —
it reflects what the customer actually keeps.

---

## Step 3 — Commitment Burndown (burndown dataset)

**Business meaning:** How current commitments spend down over the next 1–3 years,
broken out by offering type. Useful for renewal planning.

### Chart F — Forward burndown by offering sub-type

```
selection:
  dimensions: [usage_day, pricing_offering_sub_type]
  measures:   [discounted_total_amortized_cost]
filters:
  usage_day: { gte: <today>, lt: <3_years_from_today> }
order_by: [{ field: usage_day, direction: asc }]
```

**Summarize as:** "Your current commitments run through [latest end date]. The largest
block expires around [date], primarily [offering_sub_type]. Plan renewals 60–90 days
before that date to avoid coverage gaps."

**Watch for:** Cliff-shaped burndown (large block expiring at once) vs. gradual — a
cliff signals renewal risk. Multiple sub-types expiring in the same window compound
the risk.

---

## Date range guidance

Use ISO-8601 date literals. Never use SQL functions like `NOW()` or `CURRENT_DATE`.

| Window | Compute as |
|---|---|
| Trailing 30 days | gte = today minus 30 days, lt = today |
| Trailing 3 months | gte = first day of month 3 months ago, lt = first day of current month |
| Forward 3 years | gte = today, lt = today plus 3 years |

If the user specifies a different range ("last quarter", "YTD", "past 6 months"),
translate to absolute ISO-8601 bounds before querying.

---

## Pagination

`query_dataset` supports SQL-level pagination via `limit` (page size) and `offset`
(row skip) inside the query object.

Server constraints:
- Default page size: **1,000 rows** (applied when `limit` is omitted)
- Maximum page size: **5,000 rows**

**Omit `limit` on the first call** — let the 1,000-row default apply. If the response
comes back with `truncated: true`, the result set is larger than one page: switch to
paginating with `limit: 5000` and `offset` to collect the remaining rows efficiently.

```
call 1: {selection: {...}}
  → returned_rows=1000, truncated=true
call 2: {selection: {...}, limit: 5000, offset: 1000}
  → returned_rows=5000, truncated=true
call 3: {selection: {...}, limit: 5000, offset: 6000}
  → returned_rows=834, truncated=false  ← done, concatenate all pages
```

Rules:
- Increment `offset` by `returned_rows` each iteration — the last page is often
  shorter than `limit`.
- `truncated` is heuristic: a full page (`returned_rows == limit`) reports `truncated:
  true`. On an exact-fit last page the next call returns zero rows — that also
  terminates the loop.
- Drive the loop from `truncated` and `returned_rows` only. Do not parse
  `truncation_message` strings — their wording may change server-side.
- Keep every other query parameter identical across pages.
- **Measures-only queries** (no `dimensions`): the server cannot inject a stable sort
  for these. Either supply your own `order_by` or skip pagination — measures-only
  queries are typically a single aggregate row anyway.

---

## Result presentation

- Accumulate all pages before presenting (see Pagination above). Do not report partial
  results mid-pagination.
- Check `applied_policies` and surface any row-level restrictions to the user.
- Use business language throughout — never expose dimension IDs, measure IDs, dataset
  IDs, or table names.
- For rate fields (savings rate, coverage rate), format as percentages.
- For cost/savings fields, format as currency with appropriate scale ($1.2M, $340K).
- Lead with the headline number, then the trend, then notable breakdowns.

---

## Generating visuals

After all queries are complete, produce **one single artifact** that contains all charts
as a unified dashboard. Do not render separate artifacts per chart — a single combined
component is faster to generate and easier for the user to read.

**In Claude:** Render one React artifact (using Recharts) with all six charts laid out
as a dashboard. Chart A and B → line charts with one series per product category. Chart C →
grouped or stacked bar chart by commitment type across months. Charts D and E → scalar
KPI cards. Chart F → area chart showing the burndown curve per offering sub-type. Pass
query result rows directly as data — do not hardcode values. Label axes and add a legend
where there are multiple series.

**In Cursor:** Create a single canvas containing all charts. Use Cursor's canvas feature
to render the full dashboard inline. Apply the same chart-type guidance as above.

---

## Handling gaps and errors

- If a dataset is missing from `list_datasets`, tell the user which section is
  unavailable and continue with the remaining datasets.
- If `describe_dataset` returns no measures matching the expected ids, re-read the
  schema and adapt — the canonical ids above are from the template but field names
  can vary by tenant configuration.
- If `query_dataset` returns zero rows, check whether the date filter excludes all
  data (current month is often excluded from savings datasets by default — try
  shifting the end date back one month).
