---
name: commitment-recommendations
description: >
  Surface nOps Commitment Management recommendations alongside realized savings so
  the user can see what additional savings they could unlock and validate them
  against recent actual performance. Trigger when the user asks about commitment
  recommendations, recommended RI/SP purchases, projected savings, "what should I
  buy", recommendation savings, or the nOps rate optimization program. Also trigger
  for: "show me my commitment recommendations", "what is nOps recommending I buy",
  "how much more could I save", "are last month's recommendations paying off".
---

# Commitment Recommendations

This skill produces a structured view across two domains:

1. **Recommended Savings (forward-looking)** — additional annual savings nOps is
   recommending across Compute, Databases, and AI Platforms from the latest
   recommendation cycle, broken out by product category over the next four years.
2. **Realized Savings (validation)** — actual daily realized savings versus
   on-demand pricing for the most recent complete month, broken out by product
   category, so the user can compare recommendations to what is actually being
   saved.

---

## Step 0 — Discover datasets

Call `list_datasets`. Match the results to these two datasets by name or description:

| Logical name | Matches dataset named… |
|---|---|
| `recommendations` | "Recommendations" — nOps Commitment Management recommendations for Compute, Databases, and AI |
| `cm_analysis` | "Commitment Management Analysis" — hourly semantic layer for the CM analysis table |

If only one of the two is present, proceed with what is available and note the gap.

If a dataset name is ambiguous — multiple results could plausibly match one of the
two logical names — **stop and ask the user to choose** from the candidates before
proceeding. Present each option with both its human-readable `name` and its
`description` from `list_datasets`. Never show dataset ids or internal identifiers.

Call `describe_dataset` for each matched dataset before querying — never assume
field IDs.

---

## Step 1 — Find the latest recommendation cycle (REQUIRED)

**This filter is mandatory for the recommendations query.** nOps generates a fresh
recommendation snapshot every month. Without filtering to a single
`commitment_generation_timestamp`, the query will sum every snapshot ever produced
and return wildly inflated numbers. Do not skip this step.

### Why a simple `order_by desc` does not work

`commitment_generation_timestamp` is stored as a human-readable string like
`"April 1, 2026"`, **not** as an ISO date. Sorting it descending sorts
**lexicographically**, so `"March 1, 2026"` comes before `"April 1, 2026"` because
`M` > `A`. A user has already hit this: the skill picked March when April was the
actual latest cycle.

### How to find the latest cycle

1. Query the distinct values of `commitment_generation_timestamp` with **no**
   `order_by`:

   ```
   selection:
     dimensions: [commitment_generation_timestamp]
   ```

   Paginate if needed (see Pagination below). Collect all distinct values.

2. **Parse each string as a real date** (e.g. `"April 1, 2026"` → 2026-04-01)
   and pick the maximum. Do not rely on string ordering.

3. Use that string **verbatim** (preserving the exact format returned by the
   dataset) as the filter value in Step 2.

If the dataset returns zero values for this dimension, the recommendations dataset
has no data — note the gap and proceed with the realized-savings query only.

---

## Step 2 — Recommended Savings (recommendations dataset)

**Business meaning:** Additional annual savings nOps is recommending across
Compute, Databases, and AI Platforms — what more the customer could unlock if they
act on the latest recommendation cycle, broken out by product category over the
next four years.

### Chart A — Projected annual savings by year, split by product category

```
selection:
  dimensions: [timeperiod_year, product_category]
  measures:   [savings_amount]
filters:
  timeperiod_year:                 { gte: <today>, lt: <today_plus_4_years> }
  commitment_generation_timestamp: [<latest_cycle_string_from_step_1>]
order_by: [{ field: timeperiod_year, direction: asc }]
```

**Required filters — both must be set:**
- `timeperiod_year` window of **today through today + 4 years** (so all
  forward-looking recommendation years are included)
- `commitment_generation_timestamp` set to a single-element array containing the
  latest cycle string from Step 1

**Summarize as:** "Based on nOps' latest recommendation cycle ([cycle date]), you
could unlock an additional $X in annual savings across Compute, Databases, and AI
Platforms over the next four years. The largest opportunities are in [category 1]
at $Y/yr and [category 2] at $Z/yr."

**Watch for:** Heavy concentration in a single product category — surface this so
the user can validate the assumption. A short-horizon-only recommendation (savings
fall to zero after year 1 or 2) suggests the recommendation assumes the user does
not renew; flag it.

---

## Step 3 — Realized Savings (cm_analysis dataset)

**Business meaning:** Actual daily realized savings versus public on-demand pricing
over the most recent complete month, broken out by product category. This is the
counterpoint to the recommendation projection — it shows whether prior
recommendations are translating into actual savings today.

### Chart B — Daily realized savings vs. public on-demand, last full month

```
selection:
  dimensions: [usage_day, product_category]
  measures:   [discounted_realized_savings_vs_public_on_demand]
filters:
  usage_day: { gte: <first_day_of_last_full_month>, lt: <first_day_of_current_month> }
order_by: [{ field: usage_day, direction: asc }]
```

**Summarize as:** "Across [last full month], you realized $X in savings versus
public on-demand pricing. Daily savings averaged $Y, peaking on [date] at $Z. The
top contributing product categories were [category 1] and [category 2]."

**Watch for:** Sharp drop-offs mid-month (a commitment expired, or workload moved
off covered usage); flat or zero days (data ingestion gap or coverage gap).

---

## Connecting recommendations to realized savings

The point of pairing these two views is to let the user judge recommendation
quality. After both queries run, compare the product-category mix:

- If the realized-savings categories match the recommendation categories, prior
  recommendations are translating into actual savings as projected.
- If the recommendation projects heavy savings in a category that shows little
  realized savings today, surface this — it likely means either (a) the user hasn't
  acted on prior recommendations in that category, or (b) usage in that category
  has changed since the projection was built.
- Note that realized savings reflect commitments already in place; the
  recommendation projects what *additional* savings new commitments would unlock.

---

## Date range guidance

Use ISO-8601 date literals. Never use SQL functions like `NOW()` or `CURRENT_DATE`.

| Window | Compute as |
|---|---|
| Today through today + 4 years | gte = today, lt = today plus 4 years |
| Last full month | gte = first day of previous month, lt = first day of current month |

The `commitment_generation_timestamp` filter is an **exact-match list**, not a
range. Pass the latest value as a single-element array. Its format is a
human-readable date string (e.g. `"April 1, 2026"`), not ISO-8601 — preserve the
exact string returned by the discovery query in Step 1.

If the user explicitly asks for a different forward window ("next year only", "next
10 years"), translate to absolute bounds before querying — but the recommended
default is today + 4 years.

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
- For savings/cost fields, format as currency with appropriate scale ($1.2M, $340K).
- Lead with the headline projection (total additional annual savings recommended over
  the 4-year window with the cycle date in parentheses), then the realized-savings
  counterpoint, then category-level breakdowns and gaps.

---

## Generating visuals

After both queries are complete, produce **one single artifact** that contains both
charts as a unified view. Do not render separate artifacts per chart — a single
combined component is faster to generate and easier for the user to read.

**In Claude:** Render one React artifact (using Recharts) with both charts laid out
side by side or stacked. Chart A → stacked or grouped bar chart with `timeperiod_year`
on the x-axis, `savings_amount` on the y-axis (currency), and one series per
`product_category`. Chart B → stacked bar chart with `usage_day` on the x-axis,
`discounted_realized_savings_vs_public_on_demand` on the y-axis, and one series per
`product_category`. Pass query result rows directly as data — do not hardcode values.
Label axes, format currency, and add a legend.

**In Cursor:** Create a single canvas containing both charts. Use Cursor's canvas
feature to render the full view inline. Apply the same chart-type guidance as above.

---

## Handling gaps and errors

- If `recommendations` is missing from `list_datasets`, tell the user the projected
  savings view is unavailable and proceed with realized savings only.
- If `cm_analysis` is missing, surface the recommendation projection without the
  realized-savings counterpoint and explain the comparison view cannot be produced.
- If Step 1 returns zero distinct `commitment_generation_timestamp` values, the
  recommendations dataset is empty — note the gap and proceed with realized savings
  only.
- If the recommendations query returns rows from multiple
  `commitment_generation_timestamp` values, the snapshot filter was applied
  incorrectly — re-run Step 1 and reapply the filter.
- If `query_dataset` returns zero rows for the realized-savings query, check whether
  the last-full-month range falls before data ingestion started; otherwise widen the
  range by one month and note the shift to the user.
