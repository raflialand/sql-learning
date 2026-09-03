# Comprehensive Execution Plan: Eksplorasi Hard Skill Data Analyst

This guide breaks down the assignment tasks into actionable, logical phases to ensure you complete the "Introduction to Data" module efficiently.

## Phase 1: Preparation & Setup
1.  **Download Dataset:** Access the [Sample Superstore Dataset](https://www.kaggle.com/datasets/bravehart/sample-superstore-dataset).
2.  **Workbook Organization:** Create a clean Excel workbook with four distinct tabs:
    *   **Raw Data:** Your source dataset.
    *   **Search Engine:** For your lookup tool (Task 2).
    *   **Analysis:** For your PivotTables (Task 3).
    *   **Dashboard:** For your final visualizations (Task 4).

---

## Phase 2: Execution Tasks

### Task 1: Data Cleansing & Formatting
*   **Remove Duplicates:** Highlight your data range > Data Tab > *Remove Duplicates*.
*   **Trim Spaces:** Create a helper column and use `=TRIM(A2)` to clean text. Copy these results and "Paste as Values" over the original data columns.
*   **Format Dates:** Select *Order Date* > Right-click > Format Cells > Date > Choose `YYYY-MM-DD`.
*   **Currency Format:** Select *Sales* and *Profit* columns > Format Cells > Currency > Select your preferred currency symbol.

### Task 2: Data Lookup & Logical Validation
*   **Search Engine:** On your "Search Engine" sheet, set a cell for *Order ID* input (e.g., cell B2).
*   **VLOOKUP/XLOOKUP:** Use an `IFERROR` wrapper to handle missing entries:
    *   Formula: `=IFERROR(VLOOKUP($B$2, 'Raw Data'!$A:$Z, column_index, FALSE), "Not Found")`
*   **Performance Categories:** On "Raw Data", add a "Sales Performance" column:
    *   Formula: `=IF(Sales<100, "LOW", IF(Sales<500, "MEDIUM", "HIGH"))`

### Task 3: Aggregation with PivotTable
*   **Create PivotTable:** Select data range > Insert > PivotTable > Choose the "Analysis" sheet.
*   **Build Table:** Drag *Region* and *Sub-Category* to "Rows" and *Sales*, *Profit* to "Values".
*   **Profit Margin (Calculated Field):**
    *   Click in PivotTable > PivotTable Analyze tab > Fields, Items, & Sets > Calculated Field.
    *   Name: `Profit Margin` | Formula: `=Profit / Sales`.
    *   Right-click the new column > Number Format > Percentage.

### Task 4: Interactive Dashboard & Slicers
*   **Create Charts:** Select PivotTable data > Insert > PivotChart (Bar for sales, Line for profit trends).
*   **Add Slicers:** Select the chart/table > PivotTable Analyze > Insert Slicer > Select *Year*, *Region*, and *Category*.
*   **Arrange:** Move charts and slicers to the "Dashboard" sheet. Align them for a professional, clean interface.

### Task 5: Formatting & Submission
*   **Aesthetics:** Go to View tab > Uncheck *Gridlines* on the "Dashboard" sheet.
*   **Error Audit:** Check formulas to ensure no `#N/A` or `#VALUE!` errors appear when performing searches.
*   **Save:** Ensure the file is saved as a standard `.xlsx` workbook.