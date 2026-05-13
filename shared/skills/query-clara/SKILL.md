---
name: query-clara
description: >
  Query Clara datasets to answer cloud cost and FinOps questions. Use when the user
  asks anything about cloud spend, costs, savings, commitments, usage, or resource
  efficiency — and no more specific skill (e.g. commitment-analysis) applies. Also
  triggers for: "ask Clara", "query Clara", "show me my cloud data", "what does Clara
  know about X", or any open-ended FinOps question without a named analysis type.
---

# Querying Clara Datasets

Clara exposes cloud cost and usage data through three tools. Always call them in order:
`list_datasets` → `describe_dataset` → `query_dataset`.

---

## Step 1 — Discover what's available

Call `list_datasets`. It returns the datasets the user has access to, each with an
`id`, `name`, and `description`. Read the descriptions — they tell you which datasets
cover which domains (commitments, savings, usage, rightsizing, etc.).

If the user's question maps clearly to one dataset, proceed with that one. If it could
span multiple, pick the most specific match first; broaden if the results are
insufficient.

---

## Step 2 — Read the schema before querying

Call `describe_dataset(dataset_id)` for every dataset you intend to query.

- `dimensions` — things to group or filter by (account, region, service, date buckets,
  commitment type, etc.)
- `measures` — numeric values to aggregate (costs, savings, usage amounts, rates)
- `constraints` — any server-enforced limits on the query

**Never guess field ids.** The ids returned by `describe_dataset` are the only valid
inputs to `query_dataset`. Display names in parentheses are for the user, not for queries.

---

## Step 3 — Build and run the query

```
query_dataset(
  dataset_id = "<id from list_datasets>",
  query = {
    "selection": {
      "dimensions": ["<dim_id>", ...],   // from describe_dataset
      "measures":   ["<meas_id>", ...]   // from describe_dataset
    },
    "filters": {                          // optional
      "<dim_id>": { "gte": "...", "lt": "..." },   // range
      "<dim_id>": ["value1", "value2"]             // IN list
    },
    "exclude_filters": { ... },           // optional, same shape as filters
    "order_by": [
      { "field": "<dim_or_meas_id>", "direction": "asc" }
    ],
    "limit": 100                          // optional
  }
)
```

Hard rules:
- `selection` is required and must contain at least one of `dimensions` or `measures`
- `filters` must be a JSON object keyed by dimension id — never an array of objects
- Never include `client_id` — tenant scoping is enforced server-side
- No raw SQL, JOINs, `computed_fields`, `group_by`, or `aggregations`
- All date values must be ISO-8601 literals (`"2026-01-01"`) — never SQL date functions

---

## Date range guidance

Always use absolute ISO-8601 bounds. Translate user phrases before querying:

| User says | Translate to |
|---|---|
| "last month" | gte = first day of last month, lt = first day of current month |
| "this quarter" | gte = first day of current quarter, lt = today |
| "YTD" | gte = Jan 1 of current year, lt = today |
| "last 30 days" | gte = today minus 30 days, lt = today |
| "last 90 days" | gte = today minus 90 days, lt = today |

Note: savings datasets often exclude the current month by default. If a query returns
zero rows for a range ending today, shift the end bound back to the first of the
current month.

---

## Choosing dimensions

Match the user's question to dimension granularity:

| User asks about | Useful dimensions |
|---|---|
| Trends over time | `usage_day`, `usage_month`, `usage_quarter` |
| By AWS service | `product_name`, `product_category`, `product_code` |
| By account | `usage_account_id`, `usage_account_name` |
| By region | `region_code`, `region_name` |
| By commitment | `commitment_type`, `pricing_offering_sub_type`, `purchase_type` |

Start with the coarsest useful granularity (`usage_month` before `usage_day`,
`product_category` before `product_name`) and let the user drill down.

---

## Presenting results

- Check `truncated`: if true, results are capped at the row limit. Tell the user and
  offer to narrow the date range, add a filter, or increase the limit.
- Check `applied_policies`: surface any restrictions in plain language.
- Translate all field ids to business language — never show dimension ids, measure ids,
  dataset ids, or table names to the user.
- For cost/savings fields, format as currency at appropriate scale ($1.2M, $340K, $4.20).
- For rate fields, format as percentages.
- Lead with the answer to the user's question, then supporting context.

---

## When results are unexpected

- Zero rows: check date range (current month exclusion), check filter values match
  actual data (use a broader filter to verify the dimension has values).
- Unexpectedly large numbers: verify the time granularity — daily vs. monthly data
  summed over the same period produces very different totals.
- Missing expected fields: re-read `describe_dataset` output — field availability
  varies by tenant configuration and data ingestion state.
