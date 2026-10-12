#!/usr/bin/env node
/** Validate the bundled synthetic CSVs using only Node.js built-ins. */
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');

function parseCsv(relativePath) {
  const fullPath = path.join(root, relativePath);
  const text = fs.readFileSync(fullPath, 'utf8').replace(/^\uFEFF/, '').trimEnd();
  const lines = text.split(/\r?\n/);
  if (!lines.length || !lines[0]) throw new Error(`${relativePath}: file is empty`);
  const parseLine = (line) => {
    const fields = [];
    let field = '';
    let quoted = false;
    for (let i = 0; i < line.length; i += 1) {
      const char = line[i];
      if (char === '"') {
        if (quoted && line[i + 1] === '"') { field += '"'; i += 1; }
        else quoted = !quoted;
      } else if (char === ',' && !quoted) {
        fields.push(field); field = '';
      } else field += char;
    }
    if (quoted) throw new Error(`${relativePath}: unclosed quoted value`);
    fields.push(field);
    return fields;
  };
  const headers = parseLine(lines.shift());
  return lines.map((line, index) => {
    const values = parseLine(line);
    if (values.length !== headers.length) {
      throw new Error(`${relativePath}:${index + 2}: expected ${headers.length} fields, got ${values.length}`);
    }
    return Object.fromEntries(headers.map((header, i) => [header, values[i]]));
  });
}

function assert(condition, message) {
  if (!condition) throw new Error(message);
}
function uniqueSet(rows, keyFn, label) {
  const set = new Set(rows.map(keyFn));
  assert(set.size === rows.length, `${label}: duplicate key found (${set.size}/${rows.length} unique)`);
  return set;
}

const expectedRows = {
  customers: 160,
  products: 12,
  campaigns: 8,
  customer_journey: 1800,
  campaign_spend_daily: 2040,
  content_engagement: 950,
  customer_reviews: 520,
};
const tables = Object.fromEntries(Object.entries(expectedRows).map(([name, expected]) => {
  const rows = parseCsv(`data/raw/${name}.csv`);
  assert(rows.length === expected, `${name}: expected ${expected} rows, found ${rows.length}`);
  return [name, rows];
}));

uniqueSet(tables.customers, (r) => r.customer_id, 'customers.customer_id');
uniqueSet(tables.products, (r) => r.product_id, 'products.product_id');
uniqueSet(tables.campaigns, (r) => r.campaign_id, 'campaigns.campaign_id');
uniqueSet(tables.customer_journey, (r) => r.journey_id, 'customer_journey.journey_id');
uniqueSet(tables.customer_journey, (r) => r.session_id, 'customer_journey.session_id');
uniqueSet(tables.campaign_spend_daily, (r) => `${r.spend_date}|${r.campaign_id}`, 'campaign_spend_daily date/campaign');
uniqueSet(tables.content_engagement, (r) => r.engagement_id, 'content_engagement.engagement_id');
uniqueSet(tables.customer_reviews, (r) => r.review_id, 'customer_reviews.review_id');

const customerIds = new Set(tables.customers.map((r) => r.customer_id));
const productIds = new Set(tables.products.map((r) => r.product_id));
const campaignIds = new Set(tables.campaigns.map((r) => r.campaign_id));
for (const r of tables.customer_journey) {
  assert(customerIds.has(r.customer_id), `journey ${r.journey_id}: missing customer ${r.customer_id}`);
  assert(productIds.has(r.product_id), `journey ${r.journey_id}: missing product ${r.product_id}`);
  assert(campaignIds.has(r.campaign_id), `journey ${r.journey_id}: missing campaign ${r.campaign_id}`);
  assert(['Awareness', 'Consideration', 'Intent', 'Purchase'].includes(r.stage), `journey ${r.journey_id}: invalid stage`);
  assert((r.stage === 'Purchase') === (r.converted === '1'), `journey ${r.journey_id}: stage/conversion mismatch`);
  assert(Number(r.order_value) >= 0 && (r.converted === '1' || Number(r.order_value) === 0), `journey ${r.journey_id}: invalid order value`);
}
for (const r of tables.campaign_spend_daily) {
  assert(campaignIds.has(r.campaign_id), `spend row: missing campaign ${r.campaign_id}`);
  for (const field of ['spend', 'impressions', 'clicks', 'conversions', 'revenue_attributed']) {
    assert(Number(r[field]) >= 0, `spend row ${r.campaign_id}/${r.spend_date}: negative ${field}`);
  }
  assert(Number(r.clicks) <= Number(r.impressions), `spend row ${r.campaign_id}/${r.spend_date}: clicks exceed impressions`);
}
for (const r of tables.content_engagement) {
  assert(campaignIds.has(r.campaign_id), `engagement ${r.engagement_id}: missing campaign`);
  assert(productIds.has(r.product_id), `engagement ${r.engagement_id}: missing product`);
  for (const field of ['views', 'clicks', 'likes', 'shares', 'comments']) assert(Number(r[field]) >= 0, `engagement ${r.engagement_id}: negative ${field}`);
}
for (const r of tables.customer_reviews) {
  assert(customerIds.has(r.customer_id), `review ${r.review_id}: missing customer`);
  assert(productIds.has(r.product_id), `review ${r.review_id}: missing product`);
  assert(Number(r.rating) >= 1 && Number(r.rating) <= 5, `review ${r.review_id}: rating outside 1–5`);
}

console.log('Synthetic CSV validation passed.');
for (const [name, rows] of Object.entries(tables)) console.log(`  PASS  ${name.padEnd(24)} ${String(rows.length).padStart(5)} rows`);
