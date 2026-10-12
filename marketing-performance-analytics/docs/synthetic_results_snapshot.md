# Synthetic data snapshot

> This summary is generated from the bundled synthetic CSVs. It is a reproducibility aid, not an actual company performance report.

## Overall campaign metrics

| Metric | Value |
|---|---:|
| Daily campaign rows | 2,040 |
| Spend | $76,629.25 |
| Attributed revenue | $354,555.52 |
| ROAS | 4.627x |
| Attributed conversions | 3,347 |
| Cost per attributed conversion | $22.89 |
| CTR | 3.00% |
| Click-to-conversion rate | 2.59% |

## Channel roll-up

| Channel | Spend | Attributed revenue | Attributed conversions | ROAS |
|---|---:|---:|---:|---:|
| Paid Search | $35,446.99 | $240,035.14 | 2,266 | 6.772x |
| Email | $7,218.62 | $38,727.67 | 363 | 5.365x |
| Organic Search | $3,748.51 | $9,983.64 | 91 | 2.663x |
| Influencer | $8,691.34 | $20,061.63 | 192 | 2.308x |
| Paid Social | $21,523.79 | $45,747.44 | 435 | 2.125x |

## Journey and voice-of-customer snapshot

| Metric | Value |
|---|---:|
| Sessions | 1,800 |
| Purchase-stage sessions | 194 |
| Journey purchase rate | 10.78% |
| Average submitted rating | 3.783 / 5 |
| Review records | 520 |
| Content records | 950 |

### Session highest-stage counts

| Highest stage reached | Sessions | Share of sessions |
|---|---:|---:|
| Awareness | 702 | 39.00% |
| Consideration | 541 | 30.06% |
| Intent | 363 | 20.17% |
| Purchase | 194 | 10.78% |

## Notes

- The stage percentages above partition sessions by their *highest recorded stage*. The SQL view `mart.vw_customer_funnel` calculates cumulative sessions reaching each step for a funnel view.
- Campaign attributed conversions and journey purchase sessions use different synthetic measurement rules. Do not add them together.
- Ratings and order values are simulated, so any observed patterns are examples for demonstrating analysis—not recommendations based on real customer behavior.
