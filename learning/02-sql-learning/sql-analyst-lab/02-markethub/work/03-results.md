
---

-- Q1 (Overall Trends) — GMV by month, 13 months, chronological.
-- answers: the marketplace's level arc across 2025-01 .. 2026-01.
-- grain   : SUM(line_revenue) over fulfilled LINES, one row per month.

---

Findings:

| month     | gmv       |
| --------- | --------- |
| "2025-01" | 415212.33 |
| "2025-02" | 403891.37 |
| "2025-03" | 445340.06 |
| "2025-04" | 422146.35 |
| "2025-05" | 362875.01 |
| "2025-06" | 450704.06 |
| "2025-07" | 487874.98 |
| "2025-08" | 502558.50 |
| "2025-09" | 369541.76 |
| "2025-10" | 407592.82 |
| "2025-11" | 405310.44 |
| "2025-12" | 439600.23 |
| "2026-01" | 435492.71 |

---

-- Q2 (Overall Trends) — GMV by vendor, ranked DESC.
-- answers: size ranking — which sellers carry the top line today.
-- grain   : SUM(line_revenue) over fulfilled LINES, one row per vendor.

---

Findings:

| vendor_id | vendor_name          | gmv       |
| --------- | -------------------- | --------- |
| "VEN001"  | "TechSource"         | 595117.09 |
| "VEN014"  | "Ivy Commerce"       | 551876.55 |
| "VEN013"  | "Harbor Trade"       | 543397.82 |
| "VEN006"  | "Pacific Imports"    | 495898.84 |
| "VEN005"  | "Nordic Craft"       | 493703.80 |
| "VEN004"  | "Evergreen"          | 467082.85 |
| "VEN010"  | "Cedar & Co"         | 392158.44 |
| "VEN011"  | "Vista Market"       | 388581.75 |
| "VEN003"  | "Prime Supply"       | 349412.25 |
| "VEN008"  | "Atlas Wholesale"    | 317833.58 |
| "VEN002"  | "Global Goods"       | 304201.98 |
| "VEN012"  | "Summit Brands"      | 264069.81 |
| "VEN007"  | "Sunrise Trading"    | 198241.68 |
| "VEN009"  | "Metro Distributors" | 186564.18 |

---

-- Q3 (Overall Trends) — GMV by top-level category, ranked DESC.
-- answers: catalog mix — which product lines drive GMV.
-- grain   : SUM(line_revenue) over fulfilled LINES, one row per category
--           (`category` is already the TOP-LEVEL roll-up from the gold mart).

---

FIndings:

| category            | gmv        |
| ------------------- | ---------- |
| "Electronics"       | 2010913.91 |
| "Clothing"          | 1546327.67 |
| "Home & Kitchen"    | 1295606.68 |
| "Sports & Outdoors" | 695292.36  |

---

-- Q4 (Overall Trends) — GMV by buyer country, ranked DESC.
-- answers: geography — where the buyers (and growth) come from.
-- grain   : SUM(line_revenue) over fulfilled LINES, one row per country.

---

Findings:

| country       | gmv       |
| ------------- | --------- |
| "USA"         | 929335.20 |
| "Australia"   | 856436.55 |
| "Canada"      | 850945.65 |
| "Netherlands" | 766255.86 |
| "UK"          | 747073.53 |
| "France"      | 723540.59 |
| "Germany"     | 674553.24 |

---

-- Q5 (Growth Rates) — Monthly GMV + MoM% + YoY%.
-- answers: is the marketplace growing, and is there a repeating rhythm?
-- grain   : SUM(line_revenue) over fulfilled LINES → one row per month, then
--           LAG(gmv,1) = prior month, LAG(gmv,12) = same month prior year.
-- NULLs   : the FIRST month has no prior month (mom_pct NULL) and the first
--           12 months have no prior-year month (yoy_pct NULL). The NULLs
--           propagate through the division naturally — no divide-by-zero.

---

Findings

| month     | gmv       | mom_pct | yoy_pct |
| --------- | --------- | ------- | ------- |
| "2025-01" | 415212.33 | [null]  | [null]  |
| "2025-02" | 403891.37 | -2.73   | [null]  |
| "2025-03" | 445340.06 | 10.26   | [null]  |
| "2025-04" | 422146.35 | -5.21   | [null]  |
| "2025-05" | 362875.01 | -14.04  | [null]  |
| "2025-06" | 450704.06 | 24.20   | [null]  |
| "2025-07" | 487874.98 | 8.25    | [null]  |
| "2025-08" | 502558.50 | 3.01    | [null]  |
| "2025-09" | 369541.76 | -26.47  | [null]  |
| "2025-10" | 407592.82 | 10.30   | [null]  |
| "2025-11" | 405310.44 | -0.56   | [null]  |
| "2025-12" | 439600.23 | 8.46    | [null]  |
| "2026-01" | 435492.71 | -0.93   | 4.88    |

---

-- Q6 (Growth Rates) — GMV by vendor × month + MoM% + YoY% per vendor.
-- answers: which vendor is growing vs shrinking — who has momentum?
-- grain   : SUM(line_revenue) over fulfilled LINES → one row per vendor-month.
-- HARDENED: builds a dense vendor × month grid (vendors CROSS JOIN months) so
--           LAG walks TRUE calendar months — a vendor that skips a month still
--           shows gmv=0 for that month, and MoM/YoY compares against the real
--           prior month/year, not the last selling month (no silent gap-span).
--           NULLIF guards the denominator when the prior period has zero GMV
--           (→ NULL, honest "cannot divide by zero").

---

Findings

| vendor_id | vendor_name          | month     | gmv      | mom_pct | yoy_pct |
| --------- | -------------------- | --------- | -------- | ------- | ------- |
| "VEN001"  | "TechSource"         | "2025-01" | 38574.72 | [null]  | [null]  |
| "VEN001"  | "TechSource"         | "2025-02" | 34296.82 | -11.09  | [null]  |
| "VEN001"  | "TechSource"         | "2025-03" | 61152.46 | 78.30   | [null]  |
| "VEN001"  | "TechSource"         | "2025-04" | 47352.34 | -22.57  | [null]  |
| "VEN001"  | "TechSource"         | "2025-05" | 34087.54 | -28.01  | [null]  |
| "VEN001"  | "TechSource"         | "2025-06" | 42569.58 | 24.88   | [null]  |
| "VEN001"  | "TechSource"         | "2025-07" | 54114.42 | 27.12   | [null]  |
| "VEN001"  | "TechSource"         | "2025-08" | 41896.00 | -22.58  | [null]  |
| "VEN001"  | "TechSource"         | "2025-09" | 53797.08 | 28.41   | [null]  |
| "VEN001"  | "TechSource"         | "2025-10" | 37862.08 | -29.62  | [null]  |
| "VEN001"  | "TechSource"         | "2025-11" | 47048.16 | 24.26   | [null]  |
| "VEN001"  | "TechSource"         | "2025-12" | 58964.68 | 25.33   | [null]  |
| "VEN001"  | "TechSource"         | "2026-01" | 43401.21 | -26.39  | 12.51   |
| "VEN002"  | "Global Goods"       | "2025-01" | 19572.08 | [null]  | [null]  |
| "VEN002"  | "Global Goods"       | "2025-02" | 17565.04 | -10.25  | [null]  |
| "VEN002"  | "Global Goods"       | "2025-03" | 21191.56 | 20.65   | [null]  |
| "VEN002"  | "Global Goods"       | "2025-04" | 28506.03 | 34.52   | [null]  |
| "VEN002"  | "Global Goods"       | "2025-05" | 15608.38 | -45.25  | [null]  |
| "VEN002"  | "Global Goods"       | "2025-06" | 24091.21 | 54.35   | [null]  |
| "VEN002"  | "Global Goods"       | "2025-07" | 29359.34 | 21.87   | [null]  |
| "VEN002"  | "Global Goods"       | "2025-08" | 31465.90 | 7.18    | [null]  |
| "VEN002"  | "Global Goods"       | "2025-09" | 14335.99 | -54.44  | [null]  |
| "VEN002"  | "Global Goods"       | "2025-10" | 26019.84 | 81.50   | [null]  |
| "VEN002"  | "Global Goods"       | "2025-11" | 26847.85 | 3.18    | [null]  |
| "VEN002"  | "Global Goods"       | "2025-12" | 28499.49 | 6.15    | [null]  |
| "VEN002"  | "Global Goods"       | "2026-01" | 21139.27 | -25.83  | 8.01    |
| "VEN003"  | "Prime Supply"       | "2025-01" | 28029.60 | [null]  | [null]  |
| "VEN003"  | "Prime Supply"       | "2025-02" | 20436.36 | -27.09  | [null]  |
| "VEN003"  | "Prime Supply"       | "2025-03" | 15385.96 | -24.71  | [null]  |
| "VEN003"  | "Prime Supply"       | "2025-04" | 26413.97 | 71.68   | [null]  |
| "VEN003"  | "Prime Supply"       | "2025-05" | 27340.78 | 3.51    | [null]  |
| "VEN003"  | "Prime Supply"       | "2025-06" | 21226.79 | -22.36  | [null]  |
| "VEN003"  | "Prime Supply"       | "2025-07" | 27362.14 | 28.90   | [null]  |
| "VEN003"  | "Prime Supply"       | "2025-08" | 35708.58 | 30.50   | [null]  |
| "VEN003"  | "Prime Supply"       | "2025-09" | 27123.22 | -24.04  | [null]  |
| "VEN003"  | "Prime Supply"       | "2025-10" | 39205.79 | 44.55   |         |
| "VEN003"  | "Prime Supply"       | "2025-11" | 19664.78 | -49.84  | [null]  |
| "VEN003"  | "Prime Supply"       | "2025-12" | 38581.90 | 96.20   | [null]  |
| "VEN003"  | "Prime Supply"       | "2026-01" | 22932.38 | -40.56  | -18.19  |
| "VEN004"  | "Evergreen"          | "2025-01" | 28794.51 | [null]  | [null]  |
| "VEN004"  | "Evergreen"          | "2025-02" | 30754.91 | 6.81    | [null]  |
| "VEN004"  | "Evergreen"          | "2025-03" | 63096.78 | 105.16  | [null]  |
| "VEN004"  | "Evergreen"          | "2025-04" | 31619.28 | -49.89  | [null]  |
| "VEN004"  | "Evergreen"          | "2025-05" | 39159.98 | 23.85   | [null]  |
| "VEN004"  | "Evergreen"          | "2025-06" | 42978.89 | 9.75    | [null]  |
| "VEN004"  | "Evergreen"          | "2025-07" | 31169.48 | -27.48  | [null]  |
| "VEN004"  | "Evergreen"          | "2025-08" | 30541.37 | -2.02   | [null]  |
| "VEN004"  | "Evergreen"          | "2025-09" | 45543.31 | 49.12   | [null]  |
| "VEN004"  | "Evergreen"          | "2025-10" | 30190.52 | -33.71  | [null]  |
| "VEN004"  | "Evergreen"          | "2025-11" | 25925.36 | -14.13  | [null]  |
| "VEN004"  | "Evergreen"          | "2025-12" | 40112.95 | 54.72   | [null]  |
| "VEN004"  | "Evergreen"          | "2026-01" | 27195.51 | -32.20  | -5.55   |
| "VEN005"  | "Nordic Craft"       | "2025-01" | 47066.95 | [null]  | [null]  |
| "VEN005"  | "Nordic Craft"       | "2025-02" | 32498.78 | -30.95  | [null]  |
| "VEN005"  | "Nordic Craft"       | "2025-03" | 35924.35 | 10.54   | [null]  |
| "VEN005"  | "Nordic Craft"       | "2025-04" | 38626.66 | 7.52    | [null]  |
| "VEN005"  | "Nordic Craft"       | "2025-05" | 31891.69 | -17.44  | [null]  |
| "VEN005"  | "Nordic Craft"       | "2025-06" | 44916.62 | 40.84   | [null]  |
| "VEN005"  | "Nordic Craft"       | "2025-07" | 42826.49 | -4.65   | [null]  |
| "VEN005"  | "Nordic Craft"       | "2025-08" | 43860.79 | 2.42    | [null]  |
| "VEN005"  | "Nordic Craft"       | "2025-09" | 28340.93 | -35.38  | [null]  |
| "VEN005"  | "Nordic Craft"       | "2025-10" | 39304.20 | 38.68   | [null]  |
| "VEN005"  | "Nordic Craft"       | "2025-11" | 41834.08 | 6.44    | [null]  |
| "VEN005"  | "Nordic Craft"       | "2025-12" | 35933.05 | -14.11  | [null]  |
| "VEN005"  | "Nordic Craft"       | "2026-01" | 30679.21 | -14.62  | -34.82  |
| "VEN006"  | "Pacific Imports"    | "2025-01" | 28339.93 | [null]  | [null]  |
| "VEN006"  | "Pacific Imports"    | "2025-02" | 31958.96 | 12.77   | [null]  |
| "VEN006"  | "Pacific Imports"    | "2025-03" | 46729.05 | 46.22   | [null]  |
| "VEN006"  | "Pacific Imports"    | "2025-04" | 46575.22 | -0.33   | [null]  |
| "VEN006"  | "Pacific Imports"    | "2025-05" | 30689.40 | -34.11  | [null]  |
| "VEN006"  | "Pacific Imports"    | "2025-06" | 50821.05 | 65.60   | [null]  |
| "VEN006"  | "Pacific Imports"    | "2025-07" | 46549.41 | -8.41   | [null]  |
| "VEN006"  | "Pacific Imports"    | "2025-08" | 37784.43 | -18.83  | [null]  |
| "VEN006"  | "Pacific Imports"    | "2025-09" | 35231.63 | -6.76   | [null]  |
| "VEN006"  | "Pacific Imports"    | "2025-10" | 38728.28 | 9.92    | [null]  |
| "VEN006"  | "Pacific Imports"    | "2025-11" | 36549.57 | -5.63   | [null]  |
| "VEN006"  | "Pacific Imports"    | "2025-12" | 33184.66 | -9.21   | [null]  |
| "VEN006"  | "Pacific Imports"    | "2026-01" | 32757.25 | -1.29   | 15.59   |
| "VEN007"  | "Sunrise Trading"    | "2025-01" | 10222.92 | [null]  | [null]  |
| "VEN007"  | "Sunrise Trading"    | "2025-02" | 17765.68 | 73.78   | [null]  |
| "VEN007"  | "Sunrise Trading"    | "2025-03" | 11317.91 | -36.29  | [null]  |
| "VEN007"  | "Sunrise Trading"    | "2025-04" | 24479.95 | 116.29  | [null]  |
| "VEN007"  | "Sunrise Trading"    | "2025-05" | 17011.00 | -30.51  | [null]  |
| "VEN007"  | "Sunrise Trading"    | "2025-06" | 16250.78 | -4.47   | [null]  |
| "VEN007"  | "Sunrise Trading"    | "2025-07" | 20727.21 | 27.55   | [null]  |
| "VEN007"  | "Sunrise Trading"    | "2025-08" | 15686.79 | -24.32  | [null]  |
| "VEN007"  | "Sunrise Trading"    | "2025-09" | 7075.24  | -54.90  | [null]  |
| "VEN007"  | "Sunrise Trading"    | "2025-10" | 10918.66 | 54.32   | [null]  |
| "VEN007"  | "Sunrise Trading"    | "2025-11" | 24527.56 | 124.64  | [null]  |
| "VEN007"  | "Sunrise Trading"    | "2025-12" | 9292.42  | -62.11  | [null]  |
| "VEN007"  | "Sunrise Trading"    | "2026-01" | 12965.56 | 39.53   | 26.83   |
| "VEN008"  | "Atlas Wholesale"    | "2025-01" | 27559.74 | [null]  | [null]  |
| "VEN008"  | "Atlas Wholesale"    | "2025-02" | 27334.57 | -0.82   | [null]  |
| "VEN008"  | "Atlas Wholesale"    | "2025-03" | 22084.32 | -19.21  | [null]  |
| "VEN008"  | "Atlas Wholesale"    | "2025-04" | 22958.59 | 3.96    | [null]  |
| "VEN008"  | "Atlas Wholesale"    | "2025-05" | 17876.82 | -22.13  | [null]  |
| "VEN008"  | "Atlas Wholesale"    | "2025-06" | 29798.58 | 66.69   | [null]  |
| "VEN008"  | "Atlas Wholesale"    | "2025-07" | 19847.01 | -33.40  | [null]  |
| "VEN008"  | "Atlas Wholesale"    | "2025-08" | 27566.92 | 38.90   | [null]  |
| "VEN008"  | "Atlas Wholesale"    | "2025-09" | 22187.97 | -19.51  | [null]  |
| "VEN008"  | "Atlas Wholesale"    | "2025-10" | 19883.05 | -10.39  | [null]  |
| "VEN008"  | "Atlas Wholesale"    | "2025-11" | 20887.02 | 5.05    | [null]  |
| "VEN008"  | "Atlas Wholesale"    | "2025-12" | 26105.67 | 24.99   | [null]  |
| "VEN008"  | "Atlas Wholesale"    | "2026-01" | 33743.32 | 29.26   | 22.44   |
| "VEN009"  | "Metro Distributors" | "2025-01" | 16120.40 | [null]  | [null]  |
| "VEN009"  | "Metro Distributors" | "2025-02" | 18807.61 | 16.67   | [null]  |
| "VEN009"  | "Metro Distributors" | "2025-03" | 17394.44 | -7.51   | [null]  |
| "VEN009"  | "Metro Distributors" | "2025-04" | 11940.10 | -31.36  | [null]  |
| "VEN009"  | "Metro Distributors" | "2025-05" | 13475.99 | 12.86   | [null]  |
| "VEN009"  | "Metro Distributors" | "2025-06" | 9920.61  | -26.38  | [null]  |
| "VEN009"  | "Metro Distributors" | "2025-07" | 15799.18 | 59.26   | [null]  |
| "VEN009"  | "Metro Distributors" | "2025-08" | 15613.53 | -1.18   | [null]  |
| "VEN009"  | "Metro Distributors" | "2025-09" | 10764.32 | -31.06  | [null]  |
| "VEN009"  | "Metro Distributors" | "2025-10" | 13789.40 | 28.10   | [null]  |
| "VEN009"  | "Metro Distributors" | "2025-11" | 14067.36 | 2.02    | [null]  |
| "VEN009"  | "Metro Distributors" | "2025-12" | 17641.33 | 25.41   | [null]  |
| "VEN009"  | "Metro Distributors" | "2026-01" | 11229.91 | -36.34  | -30.34  |
| "VEN010"  | "Cedar & Co"         | "2025-01" | 22702.27 | [null]  | [null]  |
| "VEN010"  | "Cedar & Co"         | "2025-02" | 37726.64 | 66.18   | [null]  |
| "VEN010"  | "Cedar & Co"         | "2025-03" | 24116.91 | -36.07  | [null]  |
| "VEN010"  | "Cedar & Co"         | "2025-04" | 19220.90 | -20.30  | [null]  |
| "VEN010"  | "Cedar & Co"         | "2025-05" | 20595.02 | 7.15    | [null]  |
| "VEN010"  | "Cedar & Co"         | "2025-06" | 26557.39 | 28.95   | [null]  |
| "VEN010"  | "Cedar & Co"         | "2025-07" | 31944.26 | 20.28   | [null]  |
| "VEN010"  | "Cedar & Co"         | "2025-08" | 33174.64 | 3.85    | [null]  |
| "VEN010"  | "Cedar & Co"         | "2025-09" | 34087.08 | 2.75    | [null]  |
| "VEN010"  | "Cedar & Co"         | "2025-10" | 39843.84 | 16.89   | [null]  |
| "VEN010"  | "Cedar & Co"         | "2025-11" | 28126.62 | -29.41  | [null]  |
| "VEN010"  | "Cedar & Co"         | "2025-12" | 39046.44 | 38.82   | [null]  |
| "VEN010"  | "Cedar & Co"         | "2026-01" | 35016.43 | -10.32  | 54.24   |
| "VEN011"  | "Vista Market"       | "2025-01" | 30049.06 | [null]  | [null]  |
| "VEN011"  | "Vista Market"       | "2025-02" | 32931.48 | 9.59    | [null]  |
| "VEN011"  | "Vista Market"       | "2025-03" | 26085.40 | -20.79  | [null]  |
| "VEN011"  | "Vista Market"       | "2025-04" | 37616.68 | 44.21   | [null]  |
| "VEN011"  | "Vista Market"       | "2025-05" | 27261.91 | -27.53  | [null]  |
| "VEN011"  | "Vista Market"       | "2025-06" | 34397.74 | 26.18   | [null]  |
| "VEN011"  | "Vista Market"       | "2025-07" | 40682.94 | 18.27   | [null]  |
| "VEN011"  | "Vista Market"       | "2025-08" | 29198.66 | -28.23  | [null]  |
| "VEN011"  | "Vista Market"       | "2025-09" | 23886.87 | -18.19  | [null]  |
| "VEN011"  | "Vista Market"       | "2025-10" | 21348.06 | -10.63  | [null]  |
| "VEN011"  | "Vista Market"       | "2025-11" | 27979.34 | 31.06   | [null]  |
| "VEN011"  | "Vista Market"       | "2025-12" | 26516.36 | -5.23   | [null]  |
| "VEN011"  | "Vista Market"       | "2026-01" | 30627.25 | 15.50   | 1.92    |
| "VEN012"  | "Summit Brands"      | "2025-01" | 22342.66 | [null]  | [null]  |
| "VEN012"  | "Summit Brands"      | "2025-02" | 19915.00 | -10.87  | [null]  |
| "VEN012"  | "Summit Brands"      | "2025-03" | 19758.58 | -0.79   | [null]  |
| "VEN012"  | "Summit Brands"      | "2025-04" | 12321.08 | -37.64  | [null]  |
| "VEN012"  | "Summit Brands"      | "2025-05" | 8671.63  | -29.62  | [null]  |
| "VEN012"  | "Summit Brands"      | "2025-06" | 21581.07 | 148.87  | [null]  |
| "VEN012"  | "Summit Brands"      | "2025-07" | 23994.19 | 11.18   | [null]  |
| "VEN012"  | "Summit Brands"      | "2025-08" | 31788.05 | 32.48   | [null]  |
| "VEN012"  | "Summit Brands"      | "2025-09" | 10190.47 | -67.94  | [null]  |
| "VEN012"  | "Summit Brands"      | "2025-10" | 16232.22 | 59.29   | [null]  |
| "VEN012"  | "Summit Brands"      | "2025-11" | 16315.56 | 0.51    | [null]  |
| "VEN012"  | "Summit Brands"      | "2025-12" | 19635.87 | 20.35   | [null]  |
| "VEN012"  | "Summit Brands"      | "2026-01" | 41323.43 | 110.45  | 84.95   |
| "VEN013"  | "Harbor Trade"       | "2025-01" | 55470.58 | [null]  | [null]  |
| "VEN013"  | "Harbor Trade"       | "2025-02" | 46956.93 | -15.35  | [null]  |
| "VEN013"  | "Harbor Trade"       | "2025-03" | 41690.49 | -11.22  | [null]  |
| "VEN013"  | "Harbor Trade"       | "2025-04" | 38654.52 | -7.28   | [null]  |
| "VEN013"  | "Harbor Trade"       | "2025-05" | 34969.43 | -9.53   | [null]  |
| "VEN013"  | "Harbor Trade"       | "2025-06" | 35444.29 | 1.36    | [null]  |
| "VEN013"  | "Harbor Trade"       | "2025-07" | 47365.02 | 33.63   | [null]  |
| "VEN013"  | "Harbor Trade"       | "2025-08" | 63850.41 | 34.80   | [null]  |
| "VEN013"  | "Harbor Trade"       | "2025-09" | 24602.79 | -61.47  | [null]  |
| "VEN013"  | "Harbor Trade"       | "2025-10" | 38364.16 | 55.93   | [null]  |
| "VEN013"  | "Harbor Trade"       | "2025-11" | 38165.25 | -0.52   | [null]  |
| "VEN013"  | "Harbor Trade"       | "2025-12" | 30975.14 | -18.84  | [null]  |
| "VEN013"  | "Harbor Trade"       | "2026-01" | 46888.81 | 51.38   | -15.47  |
| "VEN014"  | "Ivy Commerce"       | "2025-01" | 40366.91 | [null]  | [null]  |
| "VEN014"  | "Ivy Commerce"       | "2025-02" | 34942.59 | -13.44  | [null]  |
| "VEN014"  | "Ivy Commerce"       | "2025-03" | 39411.85 | 12.79   | [null]  |
| "VEN014"  | "Ivy Commerce"       | "2025-04" | 35861.03 | -9.01   | [null]  |
| "VEN014"  | "Ivy Commerce"       | "2025-05" | 44235.44 | 23.35   | [null]  |
| "VEN014"  | "Ivy Commerce"       | "2025-06" | 50149.46 | 13.37   | [null]  |
| "VEN014"  | "Ivy Commerce"       | "2025-07" | 56133.89 | 11.93   | [null]  |
| "VEN014"  | "Ivy Commerce"       | "2025-08" | 64422.43 | 14.77   | [null]  |
| "VEN014"  | "Ivy Commerce"       | "2025-09" | 32374.86 | -49.75  | [null]  |
| "VEN014"  | "Ivy Commerce"       | "2025-10" | 35902.72 | 10.90   | [null]  |
| "VEN014"  | "Ivy Commerce"       | "2025-11" | 37371.93 | 4.09    | [null]  |
| "VEN014"  | "Ivy Commerce"       | "2025-12" | 35110.27 | -6.05   | [null]  |
| "VEN014"  | "Ivy Commerce"       | "2026-01" | 45593.17 | 29.86   | 12.95   |

---

-- Q7 (Performance) — AOV by vendor, ranked DESC.
-- answers: which vendor has the strongest basket (value lever vs volume lever)?
-- grain   : AOV = SUM(line_revenue) ÷ COUNT(DISTINCT order_id), over fulfilled
--           scope. The numerator sums LINES; the denominator counts BASKETS
--           (COUNT(DISTINCT order_id)) so a multi-line order is one basket.

---

Findings

| vendor_id | vendor_name          | aov     |
| --------- | -------------------- | ------- |
| "VEN007"  | "Sunrise Trading"    | 1708.98 |
| "VEN013"  | "Harbor Trade"       | 1607.69 |
| "VEN010"  | "Cedar & Co"         | 1468.76 |
| "VEN002"  | "Global Goods"       | 1448.58 |
| "VEN011"  | "Vista Market"       | 1444.54 |
| "VEN001"  | "TechSource"         | 1440.96 |
| "VEN004"  | "Evergreen"          | 1297.45 |
| "VEN005"  | "Nordic Craft"       | 1275.72 |
| "VEN003"  | "Prime Supply"       | 1230.32 |
| "VEN014"  | "Ivy Commerce"       | 1174.21 |
| "VEN008"  | "Atlas Wholesale"    | 1151.57 |
| "VEN012"  | "Summit Brands"      | 1128.50 |
| "VEN006"  | "Pacific Imports"    | 1121.94 |
| "VEN009"  | "Metro Distributors" | 663.93  |

---

-- Q8 (Performance) — Repeat purchase rate by vendor (%), ranked DESC.
-- answers: which vendor has the most loyal buyers (the "invest here" signal)?
-- grain   : per vendor-customer, count DISTINCT order_id (fulfilled). Then per
--           vendor: distinct customers w/ ≥2 fulfilled orders ÷ distinct
--           customers w/ ≥1 fulfilled order × 100.
-- NOTE    : an order spanning multiple vendors is counted toward EACH vendor it
--           touches (the mart's line grain already attributes each line to its
--           vendor, so a cross-vendor order appears once per vendor).

---

Findings

| vendor_id | vendor_name          | repeat_buyers | total_buyers | repeat_rate_pct |
| --------- | -------------------- | ------------- | ------------ | --------------- |
| "VEN001"  | "TechSource"         | 107           | 279          | 38.35           |
| "VEN006"  | "Pacific Imports"    | 108           | 293          | 36.86           |
| "VEN014"  | "Ivy Commerce"       | 110           | 308          | 35.71           |
| "VEN005"  | "Nordic Craft"       | 92            | 269          | 34.20           |
| "VEN004"  | "Evergreen"          | 83            | 260          | 31.92           |
| "VEN013"  | "Harbor Trade"       | 72            | 253          | 28.46           |
| "VEN012"  | "Summit Brands"      | 47            | 182          | 25.82           |
| "VEN008"  | "Atlas Wholesale"    | 53            | 206          | 25.73           |
| "VEN011"  | "Vista Market"       | 52            | 210          | 24.76           |
| "VEN010"  | "Cedar & Co"         | 50            | 213          | 23.47           |
| "VEN003"  | "Prime Supply"       | 46            | 225          | 20.44           |
| "VEN009"  | "Metro Distributors" | 45            | 224          | 20.09           |
| "VEN002"  | "Global Goods"       | 31            | 174          | 17.82           |
| "VEN007"  | "Sunrise Trading"    | 13            | 102          | 12.75           |

---

-- Q9 (0) — identify the BOTTOM vendor by fulfilled GMV (same ranking as Q2,
--         ascending). This is the anchor for the drills (a)-(d) below.
-- answers: WHICH vendor underperforms.

---

| vendor_id | vendor_name          | gmv       |
| --------- | -------------------- | --------- |
| "VEN009"  | "Metro Distributors" | 186564.18 |

---

-- Q9 (a) — category mix: GMV + share% by top-level category for the bottom
--          vendor. Scope: fulfilled orders only (GMV = line_revenue).

---

FIndings:

| category         | gmv      | share_pct |
| ---------------- | -------- | --------- |
| "Electronics"    | 73460.11 | 39.38     |
| "Home & Kitchen" | 63454.35 | 34.01     |
| "Clothing"       | 49649.72 | 26.61     |

---

-- Q9 (b) — product mix: GMV + units by product_name for the bottom vendor
--          (top ~10 by GMV). Scope: fulfilled orders only.

---

FIndings:

| product_name       | gmv      | units |
| ------------------ | -------- | ----- |
| "Product 113 Mini" | 47790.60 | 66    |
| "Product 100 Mini" | 39513.34 | 82    |
| "Product 44 Max"   | 32075.80 | 92    |
| "Product 116 Max"  | 19979.52 | 88    |
| "Product 88 Plus"  | 16450.96 | 79    |
| "Product 56 Max"   | 14927.59 | 59    |
| "Product 47 Lite"  | 13967.25 | 75    |
| "Product 37 Pro"   | 1859.12  | 68    |

---

-- Q9 (c) — shipment health: count of lines/orders by carrier and in_transit
--          status. Scope: fulfilled orders only (shipments exist ONLY for
--          fulfilled orders; Pending/Cancelled have NULL carrier). in_transit=1
--          means shipped-but-not-yet-delivered (delivery_date IS NULL).
-- grain   : lines = COUNT(*) (line rows); orders = COUNT(DISTINCT order_id).

---

Findings:

| carrier | in_transit | lines | orders |
| ------- | ---------- | ----- | ------ |
| "DHL"   | 0          | 79    | 73     |
| "DHL"   | 1          | 2     | 2      |
| "FedEx" | 0          | 61    | 58     |
| "FedEx" | 1          | 5     | 5      |
| "UPS"   | 0          | 71    | 69     |
| "UPS"   | 1          | 6     | 6      |
| "USPS"  | 0          | 69    | 63     |
| "USPS"  | 1          | 5     | 5      |

---

-- Q9 (d) — payment health: count of ORDERS (DISTINCT order_id) by
--          payment_status (paid / failed / refunded / NULL). Scope: ALL orders
--          (NO is_fulfilled filter) — payment_status IS NULL means the order
--          has NO payment row, which is a finding for Q9, not an error.
-- grain   : orders = COUNT(DISTINCT order_id), never COUNT(*) (line grain).

---

Findings:

| payment_status | orders |
| -------------- | ------ |
| "paid"         | 193    |
| "failed"       | 74     |
| "refunded"     | 73     |
| [null]         | 68     |
