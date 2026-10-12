# Analysis brief

## Stakeholder

A growth marketing manager who needs to compare campaign efficiency with observed site-session behavior and customer feedback.

## Decision to support

Allocate testing budget across channels and creative formats while identifying measurement and customer-experience gaps that should be investigated before changing spend.

## Hypotheses to investigate

1. Paid search and retargeting may show stronger direct-response performance than upper-funnel activity, but cost and volume need to be considered together.
2. Email may have efficient attributed return while reaching a narrower audience.
3. Content format and engagement differ by campaign objective.
4. Lower product ratings may cluster around specific product categories or recurring feedback themes.
5. Campaign-attributed conversions and journey purchase sessions will not match exactly because the data sources use different measurement logic.

These are questions, not pre-stated findings. The dataset is synthetic and must be analyzed before any directional conclusion is claimed.

## Deliverables

- Reusable SQL Server source tables and transformation views.
- Campaign, channel, funnel, content, customer, and review analysis queries.
- Power BI semantic model and dashboard specification.
- Quality checks with explicit measurement limitations.

## Out of scope

Incrementality testing, multi-touch attribution, predictive LTV, live ad platform connectors, personally identifiable real customer data, and causal claims about channel effectiveness.

## How success is evaluated

A reviewer can reproduce the data load, run the quality checks, inspect documented metric definitions, reproduce the primary query outputs, and follow the report plan without relying on hidden assumptions or unprovided assets.
