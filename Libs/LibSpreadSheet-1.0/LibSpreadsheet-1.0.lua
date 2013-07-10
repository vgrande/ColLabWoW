	--[[
Name: LibSpreadsheet-1.0
Revision: $Rev: 76 $
Author(s): Humbedooh
Description: Spreadsheet stuff
Dependencies: LibStub AceGUI-3.0
License: GPL v3 or later.
]]
-----------------------------------------------------------------------
if ( dofile ) then
    dofile([[..\LibStub\LibStub.lua]]);
end
local SPREADSHEET = "LibSpreadsheet-1.0"
local SPREADSHEET_MINOR = tonumber(("$Rev: 076 $"):match("(%d+)")) or 10000;
if not LibStub then error(SPREADSHEET .. " requires LibStub.") end
_G.LibSpreadsheet = LibStub:NewLibrary(SPREADSHEET, SPREADSHEET_MINOR)
if not LibSpreadsheet then return end


if ( table.wipe == nil ) then
    table.wipe = function(obj) obj = {}; end;
end
--[[
LibSpreadsheet-1.0 DEFAULTS
]]--
LibSpreadsheet.disabled = LibSpreadsheet.disabled or nil;
LibSpreadsheet.sheets = {};
LibSpreadsheet.books = {};
LibSpreadsheet.cols = {'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z', '?'};
LibSpreadsheet.frameBuffer = {};
LibSpreadsheet.sortAscending = 1;
LibSpreadsheet.sortDescending = 2;
LibSpreadsheet.sortAscendingWithCase = 3;
LibSpreadsheet.sortDescendingWithCase = 4;
LibSpreadsheet.callbackEvents = { 'OnClick', 'OnEnter', 'OnLeave', 'OnSelectionChange', 'OnUserInputProcessed', 'OnUserInputRequested', 'OnUserSortRequested', 'OnUserSortProcessed' }
LibSpreadsheet.MathFuncs = {
    {func = "", internal = false, caller = ""},
    {func = "NUM", internal = false, caller = "tonumber"},
    {func = "LEN", internal = false, caller = "string.len"},
    {func = "MAX", internal = false, caller = "math.max"},
    {func = "MIN", internal = false, caller = "math.min"},
    {func = "ABS", internal = false, caller = "math.abs"},--
    {func = "SIN", internal = false, caller = "math.sin"},
    {func = "SINH", internal = false, caller = "math.sinh"},
    {func = "TAN", internal = false, caller = "math.tan"},
    {func = "TANH", internal = false, caller = "math.tanh"},
    {func = "COS", internal = false, caller = "math.cos"},--
    {func = "COSH", internal = false, caller = "math.cosh"},--
    {func = "LN", internal = false, caller = "math.log"},
    {func = "LOG", internal = false, caller = "LibSpreadsheetMath:Math_Logarithm"},
    {func = "POW", internal = false, caller = "math.pow"},
    {func = "SQRT", internal = false, caller = "math.sqrt"},
    {func = "MOD", internal = false, caller = "math.fmod"},
    {func = "SELECT", internal = false, caller = "select"},
    {func = "FLOOR", internal = false, caller = "LibSpreadsheetMath:Math_Floor"},--
    {func = "CEIL", internal = false, caller = "LibSpreadsheetMath:Math_Ceil"},--
    {func = "SUM", internal = false, caller = "LibSpreadsheetMath:Math_Sum"},
	{func = "SUMIF", internal = false, caller = "LibSpreadsheetMath:Math_SumIf"},
	{func = "COUNT", internal = false, caller = "LibSpreadsheetMath:Math_Count"},
	{func = "COUNTIF", internal = false, caller = "LibSpreadsheetMath:Math_CountIf"},
    {func = "STDEV", internal = false, caller = "LibSpreadsheetMath:Math_StdDev"},
    {func = "LIST", internal = true, caller = "_G.LibSpreadsheetTemp:ListCellsMath"},
    {func = "UNIQUE", internal = false, caller = "LibSpreadsheetMath:Math_Unique"},
    {func = "IF", internal = false, caller = "LibSpreadsheetMath:Math_If"},
    {func = "AND", internal = false, caller = "LibSpreadsheetMath:Math_And"},
    {func = "OR", internal = false, caller = "LibSpreadsheetMath:Math_Or"},
    {func = "LARGE", internal = false, caller = "LibSpreadsheetMath:Math_Large"},
    {func = "SMALL", internal = false, caller = "LibSpreadsheetMath:Math_Small"},
    {func = "MEDIAN", internal = false, caller = "LibSpreadsheetMath:Math_Median"},
    {func = "AVERAGE", internal = false, caller = "LibSpreadsheetMath:Math_Average"},
    {func = "AVG", internal = false, caller = "LibSpreadsheetMath:Math_Average"},
    {func = "MEAN", internal = false, caller = "LibSpreadsheetMath:Math_Average"},
    {func = "MODE", internal = false, caller = "LibSpreadsheetMath:Math_Mode"},
    {func = "ROUND", internal = false, caller = "LibSpreadsheetMath:Math_Round"},

    --- WoW API calls, courtesy of Sylvanaar's brain --
    {unitFunc = true, func = "HEALTH", internal = true, caller = "UnitHealth"},
    {unitFunc = true, func = "POWER", internal = true, caller = "UnitPower"},
    {unitFunc = true, func = "MAXHEALTH", internal = true, caller = "UnitHealthMax"},
    {unitFunc = true, func = "MAXPOWER", internal = true, caller = "UnitPowerMax"},
    {unitFunc = true, func = "MONEY", internal = true, caller = "GetMoney"},
    {unitFunc = true, func = "LEVEL", internal = true, caller = "UnitLevel"},
    {unitFunc = true, func = "ARMOR", internal = true, caller = "UnitArmor"},
    {unitFunc = true, func = "CLASS", internal = true, caller = "UnitClass"},
    {unitFunc = true, func = "RACE", internal = true, caller = "UnitRace"},
    {unitFunc = true, func = "MOBTYPE", internal = true, caller = "UnitClassification"},
    {unitFunc = true, func = "NAME", internal = true, caller = "UnitName"},
    {unitFunc = true, func = "STRENGTH", internal = true, caller = "UnitStat", sufffix = 1},
    {unitFunc = true, func = "AGILITY", internal = true, caller = "UnitStat", suffix = 2},
    {unitFunc = true, func = "STAMINA", internal = true, caller = "UnitStat", suffix = 3},
    {unitFunc = true, func = "INTELLECT", internal = true, caller = "UnitStat", suffix = 4},
    {unitFunc = true, func = "SPIRIT", internal = true, caller = "UnitStat", suffix = 5},
    -- Drag types: Item, Spell, Money?, Name?
    };


function LibSpreadsheet:Export(format, from, to)
    local rowTable = self.rows;
    if ( self.hasFilters or self.hasGroups ) then
        rowTable = self.rowHeap;
    end
    if ( from == true ) then
        if ( self.selectStartRow ) then
            from = self.selectStartRow;
            to = self.selectEndRow;
        else
            from = 1;
            to = #rowTable;
        end
    end
    local tbl = {};
    for i = math.min(from, to), math.max(from,to) do
        local k = i;
        local string = format:gsub("%$(%w)",
            function(s)
            local c = tonumber(s, 36)-9;
            if ( rowTable[k].cells[c] and rowTable[k].cells[c].frame ) then return rowTable[k].cells[c].frame.label:GetText();
            else
                return k;
            end
        end);
        table.insert(tbl, string);
    end
    return tbl;
end


function LibSpreadsheet:GenerateRow(heap, loc)
    local struct = {
        c = {1,1,1,1},
        b = {0,0,0,0},
        f = nil,
        h = false,
        u = true,
        cells = {}
    };
    for key, col in pairs(self.columns or {}) do
        table.insert(struct.cells,
        {
            i = nil,
            c = nil,
            b = nil,
            id = nil,
            data = nil,
            t = col.type or "number",
            u = true,
            w = 0,
            h = false
        }
        );
    end
    if ( tonumber(loc) ) then
        table.insert(heap, loc, struct);
    else
        table.insert(heap, struct);
    end
    return heap[#heap];
end

function LibSpreadsheet:DeregisterRow(row)
    if ( row.frame ) then
        local x = #row.cells;
        for k, cell in pairs(row.cells) do
            if ( cell.frame ~= nil ) then
                LibSpreadsheet:DeleteFrame(cell.frame);
                cell.frame = nil;
            end
        end
        --table.wipe(row.cells);
        row.cells = {};
        LibSpreadsheet:DeleteFrame(row.frame);
        row.frame = nil;
        row.axis = nil;
        return x;
    end
end



local function deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

--[[
LibSpreadsheet-1.0 BOOK API
]]--

function LibSpreadsheet:SetupSheet(sheet, book)
    table.insert(LibSpreadsheet.sheets, sheet);
    local xbook = book;
    sheet.parent =                    function() return xbook; end;
    sheet.rowHeap =                   {}
    sheet.heapChanged =               true;
    sheet.container =                 nil;
    sheet.GenerateHeap =              LibSpreadsheet.GenerateHeap;
    sheet.GenerateRow  =              LibSpreadsheet.GenerateRow;
    sheet.DeregisterRow =             LibSpreadsheet.DeregisterRow;
    sheet.AddColumn =                 LibSpreadsheet.AddColumn;
    sheet.AddColumnAt =               LibSpreadsheet.AddColumnAt;
    sheet.SetColumn =                 LibSpreadsheet.SetColumn;
    sheet.DeleteColumn =              LibSpreadsheet.DeleteColumn;
    sheet.ExtractLocation =           LibSpreadsheet.ExtractLocation;
    sheet.AddRow =                    LibSpreadsheet.AddRow;
    sheet.AddRowAt =                  LibSpreadsheet.AddRowAt;
    sheet.DeleteRow =                 LibSpreadsheet.DeleteRow;
    sheet.GetValue =                  LibSpreadsheet.GetValue;
    sheet.Insert =                    LibSpreadsheet.Insert;
    sheet.Delete =                    LibSpreadsheet.Delete;
    sheet.SetCellValue =              LibSpreadsheet.SetCellValue;
    sheet.StartSelect =               LibSpreadsheet.StartSelect;
    sheet.EndSelect =                 LibSpreadsheet.EndSelect;
    sheet.SetVisibleSelection =       LibSpreadsheet.SetVisibleSelection;
    sheet.UpdateSelect =              LibSpreadsheet.UpdateSelect;
    sheet.SetInteractive =            LibSpreadsheet.SetInteractive;
    sheet.SetColorRange =             LibSpreadsheet.SetColorRange;
    sheet.SetRow =                    LibSpreadsheet.SetRow;
    sheet.ClearCells =                LibSpreadsheet.ClearCells;
    sheet.SortByColumn =              LibSpreadsheet.SortByColumn;
    sheet.SetCallback =               LibSpreadsheet.SetSheetCallback;
    sheet.UpdateFrameSizes =          LibSpreadsheet.UpdateFrameSizes;
    sheet.ShowEditBox =               LibSpreadsheet.ShowEditBox;
    sheet.SaveEditBox =               LibSpreadsheet.SaveEditBox;
    sheet.SetCellSpacing =            LibSpreadsheet.SetCellSpacing;
    sheet.SetCellPadding =            LibSpreadsheet.SetCellPadding;
    sheet.GroupBy =                   LibSpreadsheet.GroupByColumn;
    sheet.UpdateHeap =                LibSpreadsheet.UpdateHeap;
    sheet.GetUniqueValues =           LibSpreadsheet.GetUniqueValues;
    sheet.GetUniqueValuesMath =       LibSpreadsheet.GetUniqueValuesMath;
    sheet.AddFilter =                 LibSpreadsheet.AddFilter;
    sheet.ClearFilters =              LibSpreadsheet.ClearFilters;
    sheet.HideColumn =                LibSpreadsheet.HideColumn;
    sheet.ShowColumn =                LibSpreadsheet.ShowColumn;
    sheet.Commit =                    LibSpreadsheet.Commit;
    sheet.Export =                    LibSpreadsheet.Export;
    sheet.ParseMath =                 LibSpreadsheet.ParseMath;
    sheet.RunMath =                   LibSpreadsheet.RunMath;
    sheet.SumCells =                  LibSpreadsheet.SumCells;
    sheet.ListCells =                 LibSpreadsheet.ListCells
    sheet.ListCellsMath =             LibSpreadsheet.ListCellsMath
    sheet.UpdateContent =             LibSpreadsheet.UpdateContent;
    sheet.GetSelectedCells =          LibSpreadsheet.GetSelectedCells;
    sheet.GetSelectedCols =           LibSpreadsheet.GetSelectedCols;
    sheet.GetSelectedRows =           LibSpreadsheet.GetSelectedRows;
    sheet.ReceiveDrag =               LibSpreadsheet.ReceiveDrag;
    sheet.Freeze =                    LibSpreadsheet.Freeze;
    sheet.colRow =                    nil;
    for k, v in pairs (sheet.columns) do
        v.frame = nil;
    end
    for k, v in pairs (sheet.rows) do
        v.frame = nil;
        v.axis = nil;
        for k, c in pairs (v.cells) do
            c.frame = nil;
            c.u = true;
        end
    end
end

function LibSpreadsheet:Load(obj)
    obj.Add =                   LibSpreadsheet.AddSheet;
    obj.Delete =                LibSpreadsheet.DeleteSheet;
    obj.Select =                LibSpreadsheet.Select;
    obj.StrictMode =            LibSpreadsheet.StrictMode;
    obj.ShowSelector =          LibSpreadsheet.ShowSelector;
    obj.ShowScrollbars =        LibSpreadsheet.ShowScrollbars;
    obj.Leaf =                  LibSpreadsheet.Leaf;
    obj.Render =                LibSpreadsheet.Render;
    obj.Hide =                  LibSpreadsheet.Hide;
    obj.BuildFramework =        LibSpreadsheet.BuildFramework;
    obj.BuildFontStrings =      LibSpreadsheet.BuildFontStrings;
    obj.SetFont =               LibSpreadsheet.SetFont;
    obj.EnableMaths =           LibSpreadsheet.EnableMaths;
    obj.ShowAxes =              LibSpreadsheet.ShowAxes;
    obj.Render_Real =           LibSpreadsheet.Render_Real;
    obj.Render_Update =         LibSpreadsheet.Render_Update;
    obj.Render_ScrollFunction = LibSpreadsheet.Render_ScrollFunction;
    obj.SetStyle =              LibSpreadsheet.SetStyle;
    obj.Close =                 LibSpreadsheet.CloseBook;
    obj.SetContextFunction =    LibSpreadsheet.SetContextFunction;
	obj.SetGlobalCallback = 	LibSpreadsheet.SetSheetCallback;
	obj.callbacks = 			{};
    obj.frame =                 nil;
    obj.initital =              true;
    obj.lastUpdate =            1;
    obj.hasBookUI =             false;
    obj.hasSelector =           false;
    obj.editbox =               nil;
    obj.headerFont =            nil;
    obj.parent =                nil;
    obj.frameBuffer =           {};
    for k, sheet in pairs(obj.sheets) do
        LibSpreadsheet:SetupSheet(sheet, obj);
    end
    if ( obj.sheets[1] ) then
        obj:Select(obj.sheets[1].title);
    end
    table.insert(LibSpreadsheet.books, obj);
    return obj;
end

function LibSpreadsheet:Book(title)
    local obj = {};
    if ( type(title) ~= "string" ) then error(("%s: Error in creating book title; Expected string, got %s!"):format(SPREADSHEET, type(title))); end

    -- Book default values
    obj.sheets =            {};
    obj.selectedSheet =     nil;
    obj.type =              'book';
    obj.title =             title;
    obj.strict =            false;
    obj.hasBookUI =         false;
    obj.hasSelector =       false;
    obj.editbox =           nil;
    obj.headerFont =        nil;
    obj.numberFont =        nil;
    obj.stringFont =        nil;
    obj.style =             "LIST";

    -- Book functions
    self:Load(obj);

    return obj;
end

function LibSpreadsheet:CloseBook()
    for k, sheet in pairs(self.sheets) do
        LibSpreadsheet:UnloadSheet(sheet, self);
    end
    self.parent = nil;
    if ( self.frame) then
        LibSpreadsheet:DeleteFrame(self.frame);
        self.frame = nil;
    end
    for key, entry in pairs(self) do
        if ( type(entry) == "function" ) then
            self[key] = nil;
        end
    end
    LibSpreadsheet.books[self] = nil;
end

function LibSpreadsheet:UnloadSheet(sheet, book)
    LibSpreadsheet.sheets[sheet] = nil;
    local tbl = {};
    local y = 0;
    for key, entry in pairs(sheet) do
        y = y + 1;
        if ( type(entry) == "function" ) then
            sheet[key] = nil;
        end
    end
    if ( sheet.colRow and sheet.colRow.SetParent ) then LibSpreadsheet:DeleteFrame(sheet.colRow); sheet.colRow = nil; end
    for key, column in pairs(sheet.columns) do
        if ( column.frame ) then
            LibSpreadsheet:DeleteFrame(column.frame);
            column.frame = nil;
            column.h = nil;
            column.height = nil;
            column.w = nil;
            column.colwidth = nil;
        end
    end
    if ( sheet.container ) then
        sheet.container:Hide();
        sheet.container:SetScript("OnSizeChanged", nil);
        sheet.container:SetScript("OnShow", nil);
        sheet.container:SetScript("OnMouseWheel", nil);
        sheet.container:EnableMouseWheel(false)
        sheet.container:SetParent(nil);
        sheet.container = nil;
		sheet.visualCoords = {1,1,1,1};
    end
    sheet.rowHeap = nil;
    for key, row in pairs(sheet.rows) do
        if ( row.frame ) then
            LibSpreadsheet:DeleteFrame(row.frame);
            row.frame = nil;
            row.u = true;
            if ( row.axis ) then
                LibSpreadsheet:DeleteFrame(row.axis);
                row.axis = nil;
            end
        end
        for key, cell in pairs(row.cells) do
            if ( cell.frame ) then
                LibSpreadsheet:DeleteFrame(cell.frame);
            end
            if ( cell.data == "" ) then cell.data = nil; end
            cell.frame = nil;
            cell.l = nil;
            cell.x = nil;
            cell.w = nil;
            cell.h = nil;
            cell.text = nil;
            cell.MathData = nil;
            cell.MathFunction = nil;
            cell.u = nil;
        end
    end
end


--[[
LibSpreadsheet-1.0 SHEET API
]]--

function LibSpreadsheet:AddSheet(title)
    if ( title == nil ) then
        title = "Sheet " .. #self.sheets+1;
    elseif ( type(title) ~= "string" ) then error(("%s: Error in setting sheet title; Expected string, got %s!"):format(SPREADSHEET, type(title))); end
    for k, v in pairs(self.sheets) do
        if ( v.title == title ) then error(("%s: Sheet \"%s\" already exists in book \"%s\"!"):format(SPREADSHEET, title, self.title)); end
    end
    local sheet = {
        parent =                    obj,
        type =                      'sheet',
        title =                     title,
        callbacks =                 {},
        columns =                   {},
        sortDirection =             LibSpreadsheet.sortAscending,
        lastColumn =                0,
        rows =                      {},
        groups =                    {},
        filters =                   {},
        hasGroups =                 false,
        hasFilters =                false,
        heapChanged =               false,
        rowHeight =                 0,
        lastRow =                   0,
        lastColumn =                0,
        currentRow =                nil,
        currentColumn =             nil,
        isInteractive =             false,
        cellSpacing =               1,
        cellPadding =               4,
        background =                {0,0,0,0},
        visualCoords =              {1,1,1,1}
    }
    LibSpreadsheet:SetupSheet(sheet, self);
    table.insert(self.sheets, sheet);
    return self:Select(sheet.title);
end

function LibSpreadsheet:DeleteSheet(title)
    local i = nil;
    if ( title == nil ) then title = self.selectedSheet.title;
    elseif ( type(title) ~= "string" ) then error(("%s: Error in deleting sheet; Invalid sheet name - expected string, got %s!"):format(SPREADSHEET, type(title))); end
    for k, v in pairs(self.sheets) do
        if ( v.title == title ) then
            if ( self.selectedSheet == v ) then
                self.selectedSheet = nil;
            end
            i = k;
            break;
        end
    end
    if ( i~= nil ) then
        LibSpreadsheet:UnloadSheet(self.sheets[i], self);
        if ( self.sheets[i].container ~= nil ) then
            LibSpreadsheet:DeleteFrame(self.sheets[i].container);
            self.sheets[i].container = nil;
        end
        table.remove(self.sheets, i);
    end
    if ( #self.sheets > 0 ) then
        self:Select(self.sheets[#self.sheets].title);
    end
end

function LibSpreadsheet:Select(sheet)
    if ( sheet == nil ) then
        return self.sheets[1];
    end
    for k, v in pairs(self.sheets) do
        if ( v.title == sheet ) then
            self.selectedSheet = v;
            if ( self.hasBookUI == true ) then
                self.verticalScrollbar:SetValue(0);
                self.horizontalScrollbar:SetValue(0);
            end
            return v;
        end
    end
    return nil;
end


--[[
LibSpreadsheet-1.0 HEADER FUNCTIONS
]]--

function LibSpreadsheet:AddColumn(...)
    for i = 1, select("#", ...) do
        local column = select(i, ...);
        if ( type(column) == "table" or type(column) == "string" ) then
            local col = {
                name =              "",
                u =                 true,
                width =             1,
                height =            1,
                c =                 {1,1,1,1},
                b =                 {0,0,0,0},
                hidden =            false,
            };
            table.insert(self.columns, col);
            if ( self:SetColumn(#self.columns, column) == false ) then
                table.remove(#self.columns);
            else
                self.lastColumn = #self.columns;
                for k, row in pairs(self.rows) do
                    table.insert(row.cells,
                        {
                        i = nil,
                        c = nil,
                        b = nil,
                        id = nil,
                        data = nil,
                        t = "string",
                        u = true,
                        w = 0,
                        h = false
                    });
                end
            end
        else
            error(("%s: Error while adding column, expected string or table, got %s!"):format(SPREADSHEET, column));
        end
    end
    self.heapChanged = true;
end

function LibSpreadsheet:SetColumn(column, properties)
    local c = self:ExtractLocation(column);
    if ( self.columns[c] == nil ) then error(("%s: Error while setting column %s: No such column!"):format(SPREADSHEET, LibSpreadsheet.cols[c])); end
    if ( self.columns[c].type == nil or self.columns[c].justify == nil ) then
        self.columns[c].type = "string";
        self.columns[c].justify = "LEFT";
    end
    if ( type(properties) == "string" ) then
        self.columns[c].name=properties;
        self.columns[c].u = true;
        self.heapChanged = true;
        return true;
    elseif ( type(properties) == "table" ) then
        for key, val in pairs(properties) do
            if ( key == "icon" ) then key = "i"; end
            if ( key == "color" ) then key = "c"; end
            if ( key == "background" ) then key = "b"; end
            if ( key == "texcoords" ) then key = "i"; end
            self.columns[c][key] = val;
            if ( key == "type" and properties.justify == nil ) then
                if ( val == "number" ) then
                    self.columns[c].justify = "RIGHT";
                else
                    self.columns[c].justify = "LEFT";
                end
            end
        end
        self.columns[c].u = true;
        self.heapChanged = true;
        return true;
    else
        error(("%s: Error while setting column properties, expected string or table, got %s!"):format(SPREADSHEET, type(properties)));
        return false;
    end
end


function LibSpreadsheet:DeleteColumn(column)
    local c = self:ExtractLocation(column);
    if ( self.columns[c] == nil ) then error(("%s: Error while deleting column %s: No such column!"):format(SPREADSHEET, LibSpreadsheet.cols[c])); end
    if ( self.columns[c].frame ) then
        LibSpreadsheet:DeleteFrame(self.columns[c].frame);
        self.columns[c].frame = nil;
    end
    table.remove(self.columns, c);
    self.lastColumn = #self.columns;
    for k, v in pairs(self.rows) do
        if ( v.cells[c] ~= nil ) then
            if ( v.cells[c].frame ~= nil ) then
                 LibSpreadsheet:DeleteFrame(v.cells[c].frame);
                 v.cells[c].frame = nil;
             end
         end
        table.remove(v.cells, c);
    end
    for k, v in pairs(self.columns) do
        v.u = true;
    end
    self.heapChanged = true;
end



--[[
LibSpreadsheet-1.0 DATA FUNCTIONS
]]--

function LibSpreadsheet:Commit()
    if ( table.maxn(self.rowHeap) > 0 ) then
        self:ClearCells(false);
        for key, row in pairs(self.rowHeap) do
            self:DeregisterRow(row);
        end
        self.rows = self.rowHeap;
        self.rowHeap = {};
    end
end

function LibSpreadsheet:ClearCells(toggle)
    for k, row in pairs(self.rows) do
        for k, cell in pairs (row.cells) do
            if ( cell.frame ) then LibSpreadsheet:DeleteFrame(cell.frame);end
        end
        if ( row.frame ) then LibSpreadsheet:DeleteFrame(row.frame); end
    end
    self.rows = {};
    self.hasFilters = false;
    self.hasGroups = false;
    if ( self.container ~= nil ) then
        LibSpreadsheet:DeleteFrame(self.container);
        self.container = nil;
    end
    if ( toggle ~= false ) then
        self.rowHeap = {};
    end
    self.heapChanged = true;
end

function LibSpreadsheet:GetUniqueValues(from, to)
    local tmp = {};
    local ret = {};
    local fc, fr = self:ExtractLocation(from);
    local tc, tr = self:ExtractLocation(to);
    if ( fr == nil ) then
        fr = 1;
    end
    if (tc == nil ) then
        tc = fc;
        tr = #self.rows;
    end
    local val = 0;
    if ( fr and tr and fc and tc ) then
        for x = math.min(fr, tr), math.max(fr,tr) do
            if ( self.rows[x] ~= nil ) then
                for y = math.min(fc, tc), math.max(fc, tc) do
                    if ( self.rows[x].cells[y] ~= nil and self.rows[x].cells[y].data ~= nil ) then
                        if ( tmp[self.rows[x].cells[y].data] == nil ) then
                            tmp[self.rows[x].cells[y].data] = 1;
                            table.insert(ret, self.rows[x].cells[y].data);
                        end
                    end
                end
            end
        end
    end
    return ret;
end

function LibSpreadsheet:GroupByColumn(...)
    table.wipe(self.groups);
    for i = 1, select("#", ...) do
        local column = self:ExtractLocation(select(i, ...));
        if ( self.columns[column] ~= nil ) then
            table.insert(self.groups, column);
        end
    end
    if ( table.maxn(self.groups) > 0 ) then
        self.hasGroups = true;
    else
        self.hasGroups = false;
    end
    self.heapChanged = true;
end

function LibSpreadsheet:ClearFilters()
    table.wipe(self.filters);
    self.heapChanged = true;
    self.hasFilters = false;
end

function LibSpreadsheet:AddFilter(...)
    for i = 1, select("#", ...) do
        local entry = select(i, ...);
        local column = self:ExtractLocation(entry[1]);
        if ( self.columns[column] ~= nil ) then
            table.insert(self.filters, {column, entry[2], entry[3]});
        end
    end
    self.hasFilters = true;
    self.heapChanged = true;
end


function LibSpreadsheet:SortByColumn(...)
    local func = function() return false; end;
    local i = select("#", ...);
    local p = 0;
    local N = 0;
    local rowTable = self.rows;
    self.heapChanged = true;
    if ( self.hasFilters or self.hasGroups ) then
        self:UpdateHeap();
        rowTable = self.rowHeap;
        self.heapChanged = false;
    end
    while ( i > p ) do
        local col = self:ExtractLocation(select((i-p-1), ...));
        local dir = select((i-p), ...);
        local l = function(x) if ( x.t == "number" or x.t == "currency" ) then return tonumber(x.MathData or x.data); else return string.lower(x.MathData or x.data or ""); end end;
        if      ( dir == LibSpreadsheet.sortAscending )         then dir = false;
        elseif  ( dir == LibSpreadsheet.sortAscendingWithCase ) then dir = false; l = function(x) return x.data; end;
        elseif  ( dir == LibSpreadsheet.sortDescending )        then dir = true;
        else                                                         dir = true;  l = function(x) return x.data; end;
        end
        p = p + 2;
        N = N + 1;
        local n = N;
        local r = dir;
        local c = col;
        if ( self.columns[c].type == "number" ) then
            l = function(x) return x.data; end;
        end
        local myFunc = func;
        func = function(a,b) if ( a == nil or b == nil ) then return; end if (l(a.cells[c]) or 0) > (l(b.cells[c]) or 0) then return r; elseif (l(a.cells[c]) or 0) == (l(b.cells[c]) or 0) then return myFunc(a,b); end return not r; end;
    end
    self.sortDirection = math.fmod(self.sortDirection, 2) + 1;
    table.sort(rowTable, func);
    for key, row in pairs(rowTable) do
        row.u = true;
    end
end


function LibSpreadsheet:AddRow(...)
    local row = self:GenerateRow(self.rows);
    for i = 1, select("#", ...) do
        local arg = select(i, ...);
        if ( type(arg) ~= "table" ) then
            arg = {data=arg};
        end
        if ( self.columns[i] ) then
            row.cells[i].data = arg.data;
            row.cells[i].c = arg.color;
            row.cells[i].i = arg.icon;
            row.cells[i].b = arg.background;
            row.cells[i].t = arg.texcoords;
            row.cells[i].id = arg.id;
            if ( self.parent().strict == true ) then
                local t =  self.columns[i].type;
                if ( t == "string" and type(arg.data) ~= "string" ) then error(("%s: Error while adding cell in column %s, expected string, got %s!"):format(SPREADSHEET, LibSpreadsheet.cols[i], type(arg.data))); end
                if ( t == "boolean" and type(arg.data) ~= "boolean" ) then error(("%s: Error while adding cell in column %s, expected boolean, got %s!"):format(SPREADSHEET, LibSpreadsheet.cols[i], type(arg.data))); end
                if ( ( t == "number" ) and type(arg.data)  ~= "number" ) then error(("%s: Error while adding cell in column %s, expected number, got %s!"):format(SPREADSHEET, LibSpreadsheet.cols[i], type(arg.data))); end
            end
        end
    end
    self.heapChanged = true;
    return #self.rows;
end

function LibSpreadsheet:AddRowAt(loc, ...)
    local row = self:GenerateRow(self.rows, loc);
    for i = 1, select("#", ...) do
        local arg = select(i, ...);
        if ( type(arg) ~= "table" ) then
            arg = {data=arg};
        end
        if ( self.columns[i] ) then
            row.cells[i].data = arg.data;
            row.cells[i].c = arg.color;
            row.cells[i].i = arg.icon;
            row.cells[i].b = arg.background;
            row.cells[i].t = arg.texcoords;
            row.cells[i].id = arg.id;
            if ( self.parent().strict == true ) then
                local t =  self.columns[i].type;
                if ( t == "string" and type(arg.data) ~= "string" ) then error(("%s: Error while adding cell in column %s, expected string, got %s!"):format(SPREADSHEET, LibSpreadsheet.cols[i], type(arg.data))); end
                if ( t == "boolean" and type(arg.data) ~= "boolean" ) then error(("%s: Error while adding cell in column %s, expected boolean, got %s!"):format(SPREADSHEET, LibSpreadsheet.cols[i], type(arg.data))); end
                if ( ( t == "number" ) and type(arg.data)  ~= "number" ) then error(("%s: Error while adding cell in column %s, expected number, got %s!"):format(SPREADSHEET, LibSpreadsheet.cols[i], type(arg.data))); end
            end
        end
    end
    self.heapChanged = true;
    return #self.rows;
end


function LibSpreadsheet:SetRow(row, properties)
    row = tonumber(row);
    if ( self.rows[row] == nil ) then error(("%s: Error while setting row properties %s: No such row!"):format(SPREADSHEET, LibSpreadsheet.cols[c])); end
    if ( type(properties) == "table" ) then
        for key, val in pairs(properties) do
            if ( key == "color" ) then key = "c"; end
            if ( key == "background" ) then key = "b"; end
            self.rows[row][key] = val;
        end
        for k, v in pairs(self.rows[row].cells) do
            v.u = true;
        end
        self.rows[row].u = true;
    end
    self.heapChanged = true;
end

function LibSpreadsheet:DeleteRow(...)
    local dels = {};
    for i = 1, select("#", ...) do
        local row = select(i, ...);
        if ( self.rows[row] ~= nil ) then
            table.insert(dels, row);
            self:DeregisterRow(self.rows[row]);
        end
    end
    table.sort(dels, function(a,b) return (a > b); end);
    for k, v in pairs(dels) do
        table.remove(self.rows, v);
    end
    for k, row in pairs(self.rows) do
        row.u = true;
        for k, cell in pairs(row.cells) do
            cell.u = true;
        end
    end
    self.heapChanged = true;
end

function LibSpreadsheet:SetCellValue(c, r, d)
    local column, row = self:ExtractLocation(c);
    if ( row ~= nil ) then
        d = r;
    else
        row = r;
    end
    if ( self.rows[row] ~= nil ) then
        if ( self.rows[row].cells[column] ~= nil ) then
            self.rows[row].cells[column].data = d;
            self.rows[row].cells[column].u = true;
        end
    end
    self.heapChanged = true;
end

function LibSpreadsheet:ExtractLocation(str)
    local col = nil;
    local row = nil;
    if ( type(str) == "string" ) then
        local c, r = (str):match("(%D+)(%d*)");
        if ( r ~= nil ) then
            row = r;
        end
        if ( string.len(c) == 1 ) then
            col = tonumber(c, 36) - 9;
        else
            for k, column in pairs(self.columns) do
                if ( column.name == c ) then
                    col = k;
                    break;
                end
            end
        end
    elseif ( type(str) == "number" ) then
        if ( str > 26 ) then str = math.fmod(str, 26); end
        if ( str < 1 ) then
            while ( str < 1 ) do
                str = str + #self.columns;
            end
        end
        col = str;
    end
    return col, tonumber(row);
end

function LibSpreadsheet:SumCells(...)
    local fc, fr = self:ExtractLocation(select(1, ...));
    local tc, tr = self:ExtractLocation(select(2, ...));
    if ( fr == nil ) then
        fr = 1;
    end
    if (tc == nil ) then
        tc = fc;
        tr = #self.rows;
    end
    local val = 0;
    if ( tr == nil ) then
        for i = 1, select('#', ...) do
            local x = select(i, ...);
            val = val + (tonumber(x) or 0);
        end
        return val;
    end
    for x = math.min(fr, tr), math.max(fr,tr) do
        for y = math.min(fc, tc), math.max(fc, tc) do
            val = val + (tonumber(self.rows[x].cells[y].data) or 0);
        end
    end
    return val;
end

function LibSpreadsheet:ListCells(from, to)
    local fc, fr = self:ExtractLocation(from);
    local tc, tr = self:ExtractLocation(to);
    if ( fr == nil ) then
        fr = 1;
    end
    if (tc == nil ) then
        tc = fc;
        tr = #self.rows;
    end
    local vals = {};
    for x = math.min(fr, tr), math.max(fr,tr) do
        for y = math.min(fc, tc), math.max(fc, tc) do
            if ( self.rows[x] and self.rows[x].cells[y]) then
                table.insert(vals, self.rows[x].cells[y].data);
            end
        end
    end
    return unpack(vals);
end

function LibSpreadsheet:ListCellsMath(from, to)
    if ( string.sub(from or "", 1) == '"' ) then return from; end
    local fc, fr = self:ExtractLocation(from);
    local tc, tr = self:ExtractLocation(to);
    if ( fr == nil ) then
        fr = 1;
    end
    if (tc == nil ) then
        tc = fc;
        tr = #self.rows;
    end
    local vals = {};
    for x = math.min(fr, tr), math.max(fr,tr) do
        for y = math.min(fc, tc), math.max(fc, tc) do
            if ( self.rows[x] and self.rows[x].cells[y] and ( tonumber(self.rows[x].cells[y].data) or  tonumber(self.rows[x].cells[y].MathData) )~= nil ) then
                local data = self.rows[x].cells[y].data;
                if ( self.rows[x].cells[y].MathData ) then
                    data = self.rows[x].cells[y].MathData;
                end
                table.insert(vals, tonumber(data));
            end
        end
    end
    return unpack(vals);
end

function LibSpreadsheet:GetValue(column, row)
    local c, r = self:ExtractLocation(column);
    if ( type(r) == "number" ) then
        row = r;
    end
    if ( self.columns[c] == nil ) then error(("%s: Error in GetValue(): No such column '%s'!"):format(SPREADSHEET, LibSpreadsheet.cols[c or 27])); end
    if ( self.rows[row] == nil ) then error(("%s: Error in GetValue(): No such row '%u'!"):format(SPREADSHEET, row)); end
    return self.rows[row].cells[c].MathData or self.rows[row].cells[c].data;
end

function LibSpreadsheet:GetRawValue(column, row)
    local c, r = self:ExtractLocation(column);
    if ( type(r) == "number" ) then
        row = r;
    end
    if ( self.columns[c] == nil ) then error(("%s: Error in GetValue(): No such column '%s'!"):format(SPREADSHEET, LibSpreadsheet.cols[c or 27])); end
    if ( self.rows[row] == nil ) then error(("%s: Error in GetValue(): No such row '%u'!"):format(SPREADSHEET, row)); end
    return self.rows[row].cells[c].data;
end


function LibSpreadsheet:Delete(fromCol, fromRow, toCol, toRow)
    local coords = {};
    if ( type(fromCol) == "number" ) then
        coords.selectStartColumn = fromCol;
        coords.selectStartRow = fromRow;
    elseif ( type(fromCol) == "string" ) then
        local c, r = self:ExtractLocation(fromCol);
        if ( type(r) == "number" ) then
            coords.selectStartColumn = c;
            coords.selectStartRow = r;
            toRow = toCol;
            toCol = fromRow;
        else
            coords.selectStartColumn = c;
            coords.selectStartRow = fromRow;
        end
    end
    if ( type(toCol) == "number" ) then
        coords.selectEndColumn = toCol;
        coords.selectEndRow = toRow;
    elseif ( type(toCol) == "string" ) then
        local c, r = self:ExtractLocation(toCol);
        if ( type(r) == "number" ) then
            coords.selectEndColumn = c;
            coords.selectEndRow = r;
        else
            coords.selectEndColumn = c;
            coords.selectEndRow = toRow;
        end
    end
    for x = math.min(coords.selectStartRow, coords.selectEndRow), math.max(coords.selectStartRow, coords.selectEndRow) do
        for y = math.min(coords.selectStartColumn, coords.selectEndColumn), math.max(coords.selectStartColumn, coords.selectEndColumn) do
            self.rows[x].cells[y].data = nil;
        end
    end
    self.heapChanged = true;
end

function LibSpreadsheet:Insert(...)

end

function LibSpreadsheet:EnableMaths(toggle)
    if ( type(toggle) ~= "boolean" ) then error(("%s: Error in setting Math mode; Expected boolean, got %s!"):format(SPREADSHEET, type(toggle))); end
    self.Maths = toggle;
end

function LibSpreadsheet:StrictMode(toggle)
    if ( type(toggle) ~= "boolean" ) then error(("%s: Error in setting strict mode; Expected boolean, got %s!"):format(SPREADSHEET, type(toggle))); end
    self.strict = toggle;
end

function LibSpreadsheet:UpdateHeap()
    if ( self.heapChanged ) then
        local x = 0;
        for key, row in pairs(self.rowHeap) do
            x = x + (self:DeregisterRow(row) or 0) + 1;
        end
--        print("Cleared " .. x .. " frames.");
        local rowTable = self.rows;
        if ( self.hasFilters ) then
            for key, entry in pairs(self.filters) do
                local tmp = {};
                local col = entry[1];
                local method = entry[2];
                local val = entry[3];
                for key, row in pairs(rowTable) do
                    if (
                        ( method == "=" and  row.cells[col].data == val ) or
                        ( method == "~=" and row.cells[col].data ~= val ) or
                        ( method == ">" and  row.cells[col].data >  val ) or
                        ( method == "<" and  row.cells[col].data <  val ) or
                        ( method == ">=" and row.cells[col].data >= val ) or
                        ( method == "<=" and row.cells[col].data <= val )
                    ) then
                        local r = deepcopy(row);
                        r.frame = nil;
                        r.u = true;
                        for k, v in pairs(r.cells) do v.frame = nil; v.u=true; end
                        table.insert(tmp, r);
                    end
                end
                rowTable = tmp;
            end
        end
        if ( self.hasGroups ) then
            local x = #rowTable;
            for key, col in pairs(self.groups) do
                local tmp = {};
                for key, row in pairs(rowTable) do
                    if ( tmp[row.cells[col].data] ~= nil ) then
                        for key, cell in pairs(row.cells) do
                            if ( self.columns[key].type == "number" and key ~= column ) then
                                tmp[row.cells[col].data].cells[key].data = (tmp[row.cells[col].data].cells[key].data or 0) + (cell.data or 0);
                            end
                        end
                    else
                        tmp[row.cells[col].data] = {cells={}};
                        for k, cell in pairs(row.cells) do
                            tmp[row.cells[col].data].cells[k] = deepcopy(cell);
                            tmp[row.cells[col].data].cells[k].frame = nil;
                            tmp[row.cells[col].data].cells[k].u = true;
                        end
                    end
                end
                local ntmp = {};
                for k, v in pairs(tmp) do
                    table.insert(ntmp, v);
                end
                table.wipe(tmp);
                rowTable = ntmp;
            end
            local y = #rowTable;
        end
        self.rowHeap = rowTable;
        self.heapChanged = false;
    end
end



--[[
LibSpreadsheet-1.0 VISUAL HANDLERS
]]--

function LibSpreadsheet:CreateFrame(t, n, o, s)
    local frame = nil;
    local xt = (t or "nil"):lower();
    if ( not LibSpreadsheet.frameBuffer[xt] ) then LibSpreadsheet.frameBuffer[xt] = {}; end
    if ( #LibSpreadsheet.frameBuffer[xt] > 0 ) then
        frame = LibSpreadsheet.frameBuffer[xt][#LibSpreadsheet.frameBuffer[xt]];
        table.remove(LibSpreadsheet.frameBuffer[xt]);
        if ( o ) then frame:SetParent(o); end
        frame:ClearAllPoints();
        frame.icon:SetTexture(nil);
        frame.background:SetTexture(nil);
        frame.overlay:Hide();
        frame.label:SetTextColor(1,1,1,1);
        frame.label:Hide();
    else
        frame = _G.CreateFrame(t,n,o,s);
        frame.label = frame:CreateFontString(nil, "DIALOG");
        frame.icon = frame:CreateTexture(nil, "DIALOG");
        frame.background = frame:CreateTexture(nil, "BACKGROUND");
        frame.overlay = frame:CreateTexture(nil, "OVERLAY");
        frame.overlay:SetAllPoints(frame);
        frame.overlay:Hide();
        frame.background:SetAllPoints(frame);
        frame.xt = xt;
    end
    return frame;
end

function LibSpreadsheet:DeleteFrame(frame)
    frame:SetParent(nil);
    frame:Hide();
    frame:SetScript("OnMouseDown", nil);
    frame:SetScript("OnMouseUp", nil);
    frame:SetScript("OnEnter", nil);
    if ( frame.xt == "button" ) then frame:SetScript("OnDoubleclick", nil); end
	if ( frame.xt == "slider" ) then frame:SetScript("OnValueChanged", nil); end
    frame:SetScript("OnSizeChanged", nil);
    frame:SetScript("OnMouseWheel", nil);
    frame.row = nil; frame.column = nil;
    table.insert(LibSpreadsheet.frameBuffer[frame.xt], frame);
end


function LibSpreadsheet:ShowSelector(toggle)
    if ( type(toggle) ~= "boolean" ) then error(("%s: Error in setting selector mode; Expected boolean, got %s!"):format(SPREADSHEET, type(toggle))); end
    self.showSelector = toggle;
end

function LibSpreadsheet:ShowScrollbars(toggle)
    if ( type(toggle) ~= "boolean" ) then error(("%s: Error in setting scrollbar visibility; Expected boolean, got %s!"):format(SPREADSHEET, type(toggle))); end
    self.showScrollbars = toggle;
end

function LibSpreadsheet:SetInteractive(toggle)
    if ( type(toggle) ~= "boolean" ) then error(("%s: Error in setting interactive mode; Expected boolean, got %s!"):format(SPREADSHEET, type(toggle))); end
    self.isInteractive = toggle;
end

function LibSpreadsheet:UpdateContent()
    local rowTable = self.rows;
    local update = false;
    if ( self.hasGroups or self.hasFilters ) then
        self:UpdateHeap();
        rowTable = self.rowHeap;
    end
    for key, row in pairs (rowTable) do
        for cellIndex, cell in pairs (row.cells) do
            if ( cell.u and self.columns[cellIndex] ) then
                update = true;
                if ( cell.err ) then
                    cell.err = nil;
                end
                if ( cell.data == nil ) then cell.data = ""; end
                if ( type(cell.data) == "string" and cell.data:sub(1,1) == "=" and self.parent().Maths == true ) then
                    cell.MathFunction = loadstring("return (" ..self:ParseMath(cell.data:sub(2), false) .. ") ");
                else
                    cell.MathFunction = nil;
                end
                if ( cell.MathFunction ) then
                    cell.MathData = nil;
                    cell.text = nil;
                    local ret, val = pcall(cell.MathFunction);
                    if ( ret == true ) then
                        cell.MathData = val;
                    else
                        cell.MathData = nil;
                        cell.err = "Math error!";
                    end
                end
                if ( cell.MathData ) then
                    cell.text = cell.MathData;
                elseif ( cell.err ) then
                    cell.text = cell.err;
                else
                    cell.text = cell.data;
                end
                if ( self.columns[cellIndex].type == "number" or cell.t == "number" ) then

                    if ( type(cell.text) == "string" and tonumber(cell.text) ~= nil ) then cell.text = tonumber(cell.text); end
                    if ( self.columns[cellIndex].colorRange ~= nil ) then
                        if ( self.columns[cellIndex].minval ~= nil and self.columns[cellIndex].maxval ~= nil ) then
                            local colors = table.maxn(self.columns[cellIndex].colorRange);
                            if ( self.columns[cellIndex].maxval ~= nil and (cell.data or 0) > self.columns[cellIndex].maxval ) then
                                cell.data = self.columns[cellIndex].maxval;
                            end
                            local where = ( ( (cell.text - self.columns[cellIndex].minval)  / (self.columns[cellIndex].maxval - self.columns[cellIndex].minval)) * (colors-1) ) + 1;
                            local p, n = math.floor(where), math.ceil(where);
                            local r = (where - p) * 100;
                            if (  self.columns[cellIndex].colorRange[p] == nil ) then
                                where = ((colors-1)/2) + 1
                                p, n = math.floor(where), math.ceil(where);
                                r = 0;
                            end
                            local color = {
                                (  ( self.columns[cellIndex].colorRange[p][1] * (100-r) ) + ( self.columns[cellIndex].colorRange[n][1] * (r) ) ) / 100,
                                (  ( self.columns[cellIndex].colorRange[p][2] * (100-r) ) + ( self.columns[cellIndex].colorRange[n][2] * (r) ) ) / 100,
                                (  ( self.columns[cellIndex].colorRange[p][3] * (100-r) ) + ( self.columns[cellIndex].colorRange[n][3] * (r) ) ) / 100
                                };
                            cell.c = {color[1], color[2], color[3]};
                            if ( self.columns[cellIndex].dominant ) then
                                for k, v in pairs(self.rows[key].cells) do
                                    v.c = {color[1], color[2], color[3]};
                                end
                            end
                        end
                    end
                    if ( type(cell.text) == "number" ) then
                        local extra = "";
                        if ( (cell.d or self.columns[cellIndex].decimals or 0) > 0 ) then
                            extra = string.sub(string.format ( ("%%.%uf"):format(cell.d or self.columns[cellIndex].decimals or 0), cell.text - math.floor(cell.text)), 2);
                        end
                        local number = ("%.0f"):format(math.floor(cell.text) or 0);
                        local left,num,right = string.match(number,'^([^%d]*%d)(%d+)(.-)$');
                        local prettyNum = (left and left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse()) or number);
                        cell.text = string.format("%s%s%s%s", (cell.p or self.columns[cellIndex].prefix or ""), prettyNum, extra, (cell.s or self.columns[cellIndex].suffix or ""));
                    end
                elseif ( self.columns[cellIndex].type == "boolean" ) then
                    if ( cell.data == true) then cell.text = "true"; else cell.text = "false"; end
                elseif ( cell.t == "currency" or self.columns[cellIndex].type == "currency" ) then
                    local gold, silver, copper = 0,0,0;
                    copper = tonumber(cell.MathData or cell.data);
                    if ( copper ~= nil ) then
                        gold = math.floor( copper / 10000);
                        copper = math.fmod(copper, 10000);
                        silver = math.floor(copper / 100);
                        copper = math.fmod(copper, 100);
                        cell.text = string.format("%02u \124TInterface\\MoneyFrame\\UI-GoldIcon:12:12\124t %02u \124TInterface\\MoneyFrame\\UI-SilverIcon:12:12\124t %02u \124TInterface\\MoneyFrame\\UI-CopperIcon:12:12\124t", gold, silver, copper);
                    end
                elseif ( cell.t == "link" or self.columns[cellIndex].type == "link" ) then
                    local t, l = (cell.data or ""):match("(%l+):(%d+)");
                    if ( t and l ) then
                        if ( t == "spell" ) then
                            local name, rank, icon = GetSpellInfo(l);
                            if ( icon ) then
                                cell.text = ("\124T%s:16:16\124t %s"):format(icon, name);
                            end
                        elseif ( t == "item" ) then
                            local itemName, itemLink, _, _, _, _, _, _,_, itemTexture = GetItemInfo(l);
                            cell.text = ("\124T%s:16:16\124t %s"):format(itemTexture, itemLink);
                        end
                    else
                        cell.text = "";
                    end
                end
            end
        end
    end
    return update;
end

function LibSpreadsheet:UpdateFrameSizes()
    local update = false;
    local rowTable = self.rows;
    if ( self.hasGroups or self.hasFilters ) then
        self:UpdateHeap();
        rowTable = self.rowHeap;
    end
    for key, header in pairs (self.columns) do
        if ( header.u or header.colwidth == nil ) then
            update = true;
            self.parent().str:SetFontObject(self.parent().headerFont);
            self.parent().str:SetText((header.name or "??") .. ":");
            local height = math.ceil(self.parent().str:GetStringHeight());
            local width = math.ceil(self.parent().str:GetStringWidth());
            if ( width < 25 ) then width = 25; end
            if ( header.h ~= height ) then header.h = height; end
            if ( header.w ~= width ) then header.w = width; end
            self.rowHeight = height + (self.cellPadding*2);
            header.colwidth = width + (self.cellPadding*2);
        end
    end
    local t = nil;
    for key, row in pairs (rowTable) do
        for key, cell in pairs (row.cells) do
            if ( self.columns[key] ) then
                t = cell.t or self.columns[key].type;
                if ( cell.u or cell.MathFunction ) then
                    if ( t == "number" ) then
                        self.parent().str:SetFontObject(self.parent().numberFont);
                        self.parent().str:SetText(cell.text);
                    else
                        self.parent().str:SetFontObject(self.parent().stringFont);
                        self.parent().str:SetText(cell.text);
                    end
                    local cw, ch = 0, 0;
                    cell.h = math.ceil(self.parent().str:GetStringHeight());
                    cell.w = math.ceil(self.parent().str:GetStringWidth() + (self.cellPadding*2) + cw) + 4;
                    if ( cell.i ) then
                        cell.w = cell.w + self.rowHeight + self.cellPadding;
                        cell.h = self.rowHeight;
                    end
                end
                if ( cell.w > self.columns[key].colwidth ) then
                    self.columns[key].colwidth = cell.w;
                end
                if ( cell.h > self.rowHeight ) then
                    self.rowHeight = cell.h + (self.cellPadding*2);
                end
            end
        end
    end
    return update;
end

function LibSpreadsheet:BuildFontStrings()
    self.str = UIParent:CreateFontString();
    local garble = string.format("%8x", math.random(time()));
    self.headerFont = CreateFont("LibSpreadsheetHeaderFont"..garble);
    self.numberFont = CreateFont("LibSpreadsheetNumberFont"..garble);
    self.stringFont = CreateFont("LibSpreadsheetStringFont"..garble);
    local locale =            (GetLocale or (function() return "enUS"; end))();
    self.numberFont:SetFont(    [[Fonts\ARIALN.TTF]],   12);
    if ( locale == "zhCN" ) then
        self.headerFont:SetFont([[Fonts\ZYKai_T.TTF]],  12);
        self.stringFont:SetFont([[Fonts\ZYKai_T.TTF]],  10);
    elseif ( locale == "zhTW" ) then
        self.headerFont:SetFont([[Fonts\bLEI00D.TTF]],  12);
        self.stringFont:SetFont([[Fonts\bLEI00D.TTF]],  10);
    elseif ( locale == "koKR" ) then
        self.headerFont:SetFont([[Fonts\2002.TTF]],     12);
        self.stringFont:SetFont([[Fonts\2002.TTF]],     10);
    else
        self.headerFont:SetFont([[Fonts\FRIZQT__.TTF]], 12);
        self.stringFont:SetFont([[Fonts\FRIZQT__.TTF]], 10);
    end
end

function LibSpreadsheet:SetFont(what, font, size, flags)
    what = string.lower(what);
    local garble = string.format("%8x", math.random(time()));
    local fontstring = CreateFont("LibSpreadsheetCustomFont"..garble);
    fontstring:SetFont(font, size, flags);
    if ( what == "header") then self.headerFont = fontstring end
    if ( what == "string") then self.headerFont = fontstring end
    if ( what == "number") then self.headerFont = fontstring end
end

function LibSpreadsheet:BuildFramework()
    if ( self.headerFont == nil ) then
        self:BuildFontStrings();
    end
    self.frame = LibSpreadsheet:CreateFrame("Frame", nil, UIParent);
    self.frame:SetScript("OnUpdate",
        function() self.frame:SetScript("OnUpdate", nil);
        self:Render_ScrollFunction();
        self.frame:SetScript("OnSizeChanged", function() self:Render_ScrollFunction(false, false, 'OnSizeChanged'); end);
        end);

    self.frame.SetVerticalScroll = function() end;
    self.frame.SetHorizontalScroll = function() end;
    self.header = nil;
    self.frame:SetPoint("CENTER", UIParent, "CENTER", 0,0);
    self.frame:SetFrameStrata("DIALOG")
    self.frame:EnableMouse(true)
    self.innerFrame = nil;
    self.frame:Hide();
    self.offsetY = 0;

    self.scrollFrame = LibSpreadsheet:CreateFrame("ScrollFrame", nil, self.frame);
    self.scrollFrame:SetAllPoints(self.frame);


    self.verticalScrollbar = LibSpreadsheet:CreateFrame("Slider", nil, self.scrollFrame, "UIPanelScrollBarTemplate");
    self.verticalScrollbar:SetOrientation('VERTICAL');
    self.verticalScrollbar:SetPoint("TOPLEFT", self.scrollFrame, "TOPRIGHT", 4, -16)
    self.verticalScrollbar:SetPoint("BOTTOMLEFT", self.scrollFrame, "BOTTOMRIGHT", 4, 16)
    self.verticalScrollbar:SetMinMaxValues(0, 20)
    self.verticalScrollbar:SetValueStep(6)
    self.verticalScrollbar:SetValue(1)
    self.verticalScrollbar:SetWidth(16)
    self.verticalScrollbar:Hide()
    self.verticalScrollbar:SetScript("OnValueChanged", function(a,b) self:Render_ScrollFunction(false,b,'vertScroll') end );

    local s2 = sqrt(2);
    local cos, sin, rad = math.cos, math.sin, math.rad;
    local function CalculateCorner(angle)
        local r = rad(angle);
        return 0.5 + cos(r) / s2, 0.5 + sin(r) / s2;
    end
    local function RotateTexture(texture, angle)
        local LRx, LRy = CalculateCorner(angle + 45);
        local LLx, LLy = CalculateCorner(angle + 135);
        local ULx, ULy = CalculateCorner(angle + 225);
        local URx, URy = CalculateCorner(angle - 45);

        texture:SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy);
    end


    local garble = string.format("%8x", math.random(time()));
    self.horizontalScrollbar = LibSpreadsheet:CreateFrame("Slider", "LibSpreadsheet_Scroller_" .. garble, self.scrollFrame, "UIPanelScrollBarTemplate");
    self.horizontalScrollbar:SetOrientation('HORIZONTAL');
    self.horizontalScrollbar:SetPoint("TOPLEFT", self.scrollFrame, "BOTTOMLEFT", 16, -5)
    self.horizontalScrollbar:SetPoint("BOTTOMRIGHT", self.scrollFrame, "BOTTOMRIGHT", 0, -21)
    self.horizontalScrollbar:SetMinMaxValues(0,20)
    self.horizontalScrollbar:SetValueStep(6);
    self.horizontalScrollbar:SetValue(1)
    self.horizontalScrollbar:Hide()
    self.horizontalScrollbar:SetScript("OnValueChanged", function(a,b,event) self:Render_ScrollFunction(b, false,'horiscroll') end );
    local tex, button;
    button = _G["LibSpreadsheet_Scroller_" .. garble .. "ScrollUpButton"];
    tex = button:GetNormalTexture(); RotateTexture(tex, 90); tex:SetPoint("TOPLEFT", button, "TOPLEFT", -8, 8); tex:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 8, -8);
    tex = button:GetPushedTexture(); RotateTexture(tex, 90); tex:SetPoint("TOPLEFT", button, "TOPLEFT", -8, 8); tex:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 8, -8);
    tex = button:GetHighlightTexture(); RotateTexture(tex, 90); tex:SetPoint("TOPLEFT", button, "TOPLEFT", -8, 8); tex:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 8, -8);
    button:ClearAllPoints();
    button:SetPoint("BOTTOMRIGHT", self.horizontalScrollbar, "BOTTOMLEFT", 0, 0);
    button:SetPoint("TOPRIGHT", self.horizontalScrollbar, "TOPLEFT", 0, 0);

    button = _G["LibSpreadsheet_Scroller_" .. garble .. "ScrollDownButton"];
    tex = button:GetNormalTexture(); RotateTexture(tex, 90); tex:SetPoint("TOPLEFT", button, "TOPLEFT", -8, 8); tex:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 8, -8);
    tex = button:GetPushedTexture(); RotateTexture(tex, 90); tex:SetPoint("TOPLEFT", button, "TOPLEFT", -8, 8); tex:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 8, -8);
    tex = button:GetHighlightTexture(); RotateTexture(tex, 90); tex:SetPoint("TOPLEFT", button, "TOPLEFT", -8, 8); tex:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 8, -8);
    button:ClearAllPoints();
    button:SetPoint("TOPLEFT", self.horizontalScrollbar, "TOPRIGHT", 0, 0);

    self.frame.onMouseWheel = function(caller, value)
        local delta = 1
        if (value or 0) < 0 then
            delta = -1
        end
        self.selectedSheet.visualCoords[2] = self.selectedSheet.visualCoords[2] - delta;
        self:Render_Update(self.selectedSheet.visualCoords[1], self.selectedSheet.visualCoords[2]);
        self.verticalScrollbar:SetValue(self.selectedSheet.visualCoords[2]*2);
    end;


    self.sheetSelector = LibSpreadsheet:CreateFrame("Frame", nil, self.frame);
    self.sheetSelector:SetFrameStrata("DIALOG")
    self.prevSheet = LibSpreadsheet:CreateFrame("Button", nil, self.sheetSelector);
    self.prevSheet:SetWidth(32);
    self.prevSheet:SetHeight(32);
    self.prevSheet:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up");
    self.prevSheet:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down");
    self.prevSheet:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled");
    self.prevSheet:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD");
    self.prevSheet:SetScript("OnClick", function() self:Leaf(-1); self:Render(); end);
    self.prevSheet:SetPoint("LEFT", self.sheetSelector, "LEFT", 0, 0);


    self.nextSheet = LibSpreadsheet:CreateFrame("Button", nil, self.sheetSelector);
    self.nextSheet:SetWidth(32);
    self.nextSheet:SetHeight(32);
    self.nextSheet:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up");
    self.nextSheet:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down");
    self.nextSheet:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled");
    self.nextSheet:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD");
    self.nextSheet:SetScript("OnClick", function() self:Leaf(1); self:Render(); end);
    self.nextSheet:SetPoint("RIGHT", self.sheetSelector, "RIGHT", 0, 0);

    self.sheetSelector:SetPoint("BOTTOMLEFT", self.frame, "BOTTOMLEFT", 0, 0);
    self.sheetSelector:SetPoint("TOPRIGHT", self.frame, "BOTTOMRIGHT", 0, 32);

    self.sheetSelectorStatus = LibSpreadsheet:CreateFrame("Frame", nil, self.sheetSelector);
    self.sheetSelectorStatus:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 3, right = 3, top = 5, bottom = 3 }
    });
    self.sheetSelectorStatus:SetAllPoints();
    self.sheetSelectorStatus:SetBackdropColor(0.1, 0.1, 0.1, 0.5);
    self.sheetSelectorStatus:SetBackdropBorderColor(0.4, 0.4, 0.4);

    self.sheetSelectorText = self.sheetSelectorStatus:CreateFontString(nil, "DIALOG");
    self.sheetSelectorText:SetFontObject(self.headerFont);
    self.sheetSelectorText:SetAllPoints(self.sheetSelectorStatus);
    self.sheetSelectorText:SetText("");
    self.sheetSelectorText:SetTextColor(0.9,0.75,0.2);
    self.sheetSelectorText:Show();

    self.editbox = LibSpreadsheet:CreateFrame("EditBox", "DIALOG", self.frame, "InputBoxTemplate");
    self.editbox:SetWidth(250)
    self.editbox:SetHeight(250)
    self.editbox:SetAutoFocus(true);
    self.editbox:SetFontObject(self.stringFont);
    self.editbox:SetScript("OnEscapePressed", function(me) me:Hide(); end);
    self.editbox:SetScript("OnHide", function(me) if ( me.caller ~= nil ) then me.caller:Show();end end);
    self.editbox:SetScript("OnEnterPressed",  function(me) if ( me.caller ~= nil ) then me.caller.sheet:SaveEditBox(me.caller, me:GetText()); me:Hide(); end end);
    self.editbox:SetTextInsets(0, 0, 3, 3);
    self.editbox:SetMaxLetters(256);
    self.editbox:Hide();
    self.hasBookUI = true;
end

function LibSpreadsheet:Hide()
    if ( self.frame ~= nil ) then
        self.frame:Hide();
    end
end

function LibSpreadsheet:Render_ScrollFunction(valueX, valueY, caller)
    local offsetX, offsetY
    if ( valueY == 1 ) then return; end
    if ( valueX ) then valueX = math.floor(valueX / 2); end
    if ( valueY ) then valueY = math.floor(valueY / 2); end
    local visualRows = self.selectedSheet.visualCoords[4] - self.selectedSheet.visualCoords[2];
    local visualCols = self.selectedSheet.visualCoords[3] - self.selectedSheet.visualCoords[1];
    local sheet = self.selectedSheet;
    local rowTable = sheet.rows;
    if ( sheet.hasFilters or sheet.hasGroups ) then
        rowTable = sheet.rowHeap or {};
    end

    if  #rowTable <= visualRows then
        offsetY = 1;
        self.verticalScrollbar:Hide()
        if ( sheet.container) then sheet.container:EnableMouseWheel(false) end
    else
        self.verticalScrollbar:Show();
        if ( sheet.container ) then
            sheet.container:EnableMouseWheel(true)
        end
        offsetY = valueY or self.selectedSheet.visualCoords[2];
    end
    if #self.selectedSheet.columns < (visualCols) then
        offsetX = 1
--        self.horizontalScrollbar:Hide();
    else
--        self.horizontalScrollbar:Show();
        offsetX = valueX or self.selectedSheet.visualCoords[1];
    end
    if ( offsetX < 1 ) then return end
    if ( offsetY < 1 ) then return end
    if ( self.lastUpdate == nil ) then
        self.lastUpdate = 0;
    end

    local now = GetTime();
    if ( now - self.lastUpdate > 0.03 ) then -- We really don't need to update more than 5 times per second, do we? ;<
        if ( self:Render_Update(offsetX, offsetY, 'scroller: ' .. (caller or "??")) ) then
            self.lastUpdate = now;
        end
    end
end

function LibSpreadsheet:Render()
    if ( self.hasBookUI == false ) then
        self:BuildFramework();
    end
    local sheet = self.selectedSheet;

    for k, s in pairs(self.sheets) do
        if ( s.container ~= nil and s.container.Hide ~= nil ) then
            s.container:Hide();
        end
    end
    --[[ SHEET AXES AND DATA CONTAINER PROTOTYPES ]]--
    if ( sheet.container == nil ) then
        sheet.container = LibSpreadsheet:CreateFrame("Frame", nil, self.frame);
        sheet.container:SetPoint("TOPLEFT");
        sheet.container:SetPoint("BOTTOMRIGHT");
        sheet.container:EnableMouse(true)
        sheet.container:SetAllPoints();
        sheet.container.background = sheet.container:CreateTexture();
        sheet.container.background:SetAllPoints(sheet.container);
        if ( sheet.background ) then
            sheet.container.background:SetTexture(unpack(sheet.background));
        end
        sheet.container:SetScript("OnMouseWheel", self.frame.onMouseWheel);
    end
    self.innerFrame = sheet.container;
    self.scrollFrame:SetScrollChild(sheet.container);
    self.scrollFrame:Show();
    sheet.container:Show();
    sheet.container:SetAllPoints(self.scrollFrame);
    self:Render_Update();
    return self.frame;
end


function LibSpreadsheet:Render_Update(colStart, rowStart, caller)
	if ( not self.frame ) then return false; end
    if ( colStart == nil ) then colStart = self.selectedSheet.visualCoords[1]; end
    if ( rowStart == nil ) then rowStart = self.selectedSheet.visualCoords[2]; end
    colStart = math.floor(colStart);
    rowStart = math.floor(rowStart);
    if ( colStart < 1 ) then colStart = 1; end
    if ( rowStart < 1 ) then rowStart = 1; end
    local bookWidth =  self.frame:GetWidth();
    local bookHeight = self.frame:GetHeight();
    local colEnd = colStart;
    local rowEnd = rowStart;
    if ( self.selectedSheet == nil or self.selectedSheet.parent == nil ) then
        return true;
    end

    local rowTable = self.selectedSheet.rows;
    if ( self.selectedSheet.hasFilters or self.selectedSheet.hasGroups ) then
        rowTable = self.selectedSheet.rowHeap;
    end
    local colTable = self.selectedSheet.columns;
    local widthUsed = 0;
    local heightUsed = 0;
    if ( (bookWidth == 0 or bookHeight == 0) and self.initial == false ) then return false; end
    local updated = self.selectedSheet:UpdateContent()
    updated = self.selectedSheet:UpdateFrameSizes() or updated;
    while ( colTable[colEnd] ~= nil and widthUsed < bookWidth ) do
        if ( not colTable[colEnd].hidden ) then
            widthUsed = widthUsed + colTable[colEnd].colwidth;
        end
        colEnd = colEnd + 1;
    end
    while ( rowTable[rowEnd] ~= nil and heightUsed < bookHeight ) do
        if ( not rowTable[rowEnd].hidden ) then
            heightUsed = heightUsed + self.selectedSheet.rowHeight;
        end
        rowEnd = rowEnd + 1;
    end
    if (colEnd > #colTable) then colEnd = #colTable; end
    if (rowEnd > #rowTable) then rowEnd = #rowTable; end
    local X = #rowTable
    if ( #rowTable == 0 ) then
        X = 1;
    end
    if ( widthUsed < bookWidth and colStart == 1) then self.horizontalScrollbar:Hide(); else self.horizontalScrollbar:Show(); end
    self.lastUpdate = GetTime();
    self.verticalScrollbar:SetMinMaxValues(2, (X*2));
    self.horizontalScrollbar:SetMinMaxValues(2, (#colTable*2));
    if ( updated or
        colStart ~= self.selectedSheet.visualCoords[1] or
        colEnd ~= self.selectedSheet.visualCoords[3] or
        rowStart ~= self.selectedSheet.visualCoords[2] or
        rowEnd ~= self.selectedSheet.visualCoords[4] or
        self.initial == true
        ) then
        self.selectedSheet.visualCoords = {colStart, rowStart, colEnd, rowEnd};
        self.initial = false;
        for x = 1, #colTable do
            if ( colTable[x].frame ) then
                colTable[x].frame:Hide();
            end
            for y = 1, #rowTable do
                if ( rowTable[y].frame ) then rowTable[y].frame:Hide() end
                if ( rowTable[y].cells[x].frame ) then
                    rowTable[y].cells[x].frame:Hide();
                end
            end
        end
        self.selectedSheet.previousCoords = {colStart, rowStart, colEnd, rowEnd};
        self:Render_Real(colStart, rowStart, colEnd, rowEnd);
        return true;
    end
    return true;
end

function LibSpreadsheet:Render_Real(colStart, rowStart, colEnd, rowEnd)
    local sheet = self.selectedSheet;
    if ( colStart == nil ) then
        colStart, rowStart, colEnd, rowEnd = unpack(sheet.visualCoords);
        sheet:UpdateContent();
        sheet:UpdateFrameSizes();
    end
    local rowTable = sheet.rows;
    if ( sheet.hasFilters or sheet.hasGroups ) then
        rowTable = sheet.rowHeap;
    end

    --[[ SET UP X AXIS ]]--
    local offsetX = 0;

    if ( self.style == "SHEET") then offsetX = 35 + sheet.cellSpacing; end
    if ( sheet.colRow == nil or sheet.colRow.SetHeight == nil ) then
        sheet.colRow = LibSpreadsheet:CreateFrame("Frame", nil, sheet.container);
    end
    sheet.colRow:SetHeight(sheet.rowHeight + sheet.cellSpacing);
    local cols = {};
    local scols = {};
    if ( self.selectedSheet.freezePoint ~= nil and self.selectedSheet.freezePoint[1] ~= nil ) then
        for index = 1, self.selectedSheet.freezePoint[1] do
            table.insert(cols, index);
            scols[index] = true;
        end
    end
    for index = colStart, colEnd do
        local found = false;
        for k, pindex in pairs(cols) do
            if ( pindex == index ) then found = true; break; end
        end
        if ( found == false ) then
            table.insert(cols, index);
        end
    end
    for k, index in pairs(cols) do
        local column = sheet.columns[index];
        if ( column and not column.hidden ) then
            if ( column.frame == nil ) then
                column.frame = LibSpreadsheet:CreateFrame("Button", nil, sheet.colRow);
                column.frame.label:SetJustifyH(column.justify or "LEFT");
                column.frame.label:SetFontObject(self.headerFont);
                column.frame.label:SetPoint("TOPLEFT", column.frame, "TOPLEFT", (sheet.cellPadding), -(sheet.cellPadding));
                column.frame.label:SetPoint("BOTTOMRIGHT", column.frame, "BOTTOMRIGHT", -(sheet.cellPadding), (sheet.cellPadding));
                column.frame.label:SetTextColor(0.9,0.75,0.2);
                column.frame.label:Show();
                column.u = true;
                if ( self.style == "SHEET") then
                    column.frame.label:SetJustifyH("CENTER");
                    column.frame.label:SetText(LibSpreadsheet.cols[index]);
                    column.frame.label:SetTextColor(0.95,0.85,0.4);
                    column.frame.label:Show();
                    column.frame.background:Show();
                    column.frame.background:SetTexture(0.12,0.16,0.28,1);
                    if ( sheet.isInteractive or sheet.columns[cellIndex].interactive ) then
                        column.frame:SetScript("OnMouseDown", function(caller, event) sheet:StartSelect({column=true, index=index}, event); end);
                        column.frame:SetScript("OnMouseUp", function(caller, event) sheet:EndSelect({column=true, index=index}, event); end);
                        column.frame:SetScript("OnEnter", function(caller, event) sheet:UpdateSelect({column=true, index=index}); end);
                        column.frame:SetScript("OnLeave", function(caller, event) sheet:UpdateSelect({column=true, index=index}); end);
                    end
                end
                column.frame:Show();
            end
            column.frame:Show();
            if ( column.u ) then
                if ( scols[index] ) then
                    column.frame.background:SetTexture(0.24,0.16,0.13,1);
                elseif ( self.style == "SHEET") then
                    column.frame.background:SetTexture(0.12,0.16,0.28,1);
                end
                column.frame.label:SetText(column.name);
                if ( self.style == "SHEET") then
                    column.frame.label:SetText(LibSpreadsheet.cols[index]);
                    if ( sheet.isInteractive or sheet.columns[cellIndex].interactive ) then
                        column.frame:SetScript("OnMouseDown", function(caller, event) sheet:StartSelect({column=true, index=index}, event); end);
                        column.frame:SetScript("OnMouseUp", function(caller, event) sheet:EndSelect({column=true, index=index}, event); end);
                        column.frame:SetScript("OnEnter", function(caller, event) sheet:UpdateSelect({column=true, index=index}); end);
                        column.frame:SetScript("OnLeave", function(caller, event) sheet:UpdateSelect({column=true, index=index}); end);
                    end

                end
                column.frame:SetPoint("BOTTOMLEFT", sheet.colRow, "BOTTOMLEFT", offsetX, 0);
                column.frame:SetWidth(column.colwidth);
                column.frame:SetHeight(sheet.rowHeight);
                if ( column.sort == true ) then
                    local k = index;
                    column.frame:SetScript("OnClick",
                        function()
                            local l = true;
                            if ( sheet.callbacks["OnUserSortRequested"] ~= nil ) then
                                if ( type(sheet.callbacks["OnUserSortRequested"]) == "function" ) then
                                    l = (sheet.callbacks["OnUserSortRequested"])(LibSpreadsheet.cols[k]);
                                end
                            end
                            if ( l ) then
                                sheet:SortByColumn(k, sheet.sortDirection);
                                self:Render_Update();
                                if ( sheet.callbacks["OnUserSortProcessed"] ~= nil ) then
                                    if ( type(sheet.callbacks["OnUserSortProcessed"]) == "function" ) then
                                        (sheet.callbacks["OnUserSortProcessed"])(LibSpreadsheet.cols[k]);
                                    end
                                end
                            end
                        end
                    );
                end
            end
            offsetX = offsetX + column.colwidth + sheet.cellSpacing;
        end
    end
    sheet.colRow:SetWidth(offsetX);
    sheet.colRow:SetParent(sheet.container);
    sheet.colRow:SetPoint("TOPLEFT", sheet.container, "TOPLEFT", 0, 0);

    --[[ SET UP ROWS AND Y AXIS ]]--

    local f = 0;
    local offsetY = sheet.colRow:GetHeight() + sheet.cellSpacing;
    local rows = {};
    local srows = {};
    if ( self.selectedSheet.freezePoint ~= nil and self.selectedSheet.freezePoint[2] ~= nil ) then
        for index = 1, self.selectedSheet.freezePoint[2] do
            table.insert(rows, index);
            srows[index] = true;
        end
    end
    for index = rowStart, rowEnd do
        local found = false;
        for k, pindex in pairs(rows) do
            if ( pindex == index ) then found = true; break; end
        end
        if ( found == false ) then
            table.insert(rows, index);
        end
    end
    for k, index in pairs(rows) do
        local row = rowTable[index];
        if not row then
--            print("Waaah!");
            break;
        end
        if ( row.frame == nil ) then
            row.frame = LibSpreadsheet:CreateFrame("Button", nil, sheet.container);
            f = f + 1;
            row.u = true;
        end
        if ( row.u ) then
            if ( row.b ~= nil ) then
                row.frame.background:SetTexture(row.b.r or row.b[1], row.b.g or row.b[2], row.b.b  or row.b[3], row.b.a or row.b[4]);
            end
        end
        row.frame:ClearAllPoints();
        row.frame:SetPoint("TOPLEFT", sheet.container, "TOPLEFT", 0, -offsetY);
        row.frame:SetHeight(sheet.rowHeight);
        row.frame:Show();
        offsetY = offsetY + sheet.rowHeight + sheet.cellSpacing;

        --[[ SET UP CELLS ]]--
        offsetX = 0;
        if ( self.style == "SHEET") then
            if ( row.axis == nil ) then
                row.axis = LibSpreadsheet:CreateFrame("Button", nil, row.frame);
                row.axis.label:SetFontObject(self.headerFont);
                row.axis.label:SetPoint("TOPLEFT", row.axis, "TOPLEFT", (sheet.cellPadding), -(sheet.cellPadding));
                row.axis.label:SetPoint("BOTTOMRIGHT", row.axis, "BOTTOMRIGHT", -(sheet.cellPadding), (sheet.cellPadding));
                row.axis.label:SetTextColor(0.95,0.85,0.4);
                row.axis.label:SetJustifyH("RIGHT");
                row.axis.background:SetTexture(0.12,0.16,0.28,1);
                row.axis.background:Show();
            end
            if ( row.u ) then
                if ( srows[index] ) then
                    row.axis.background:SetTexture(0.24,0.16,0.13,1);
                else
                    row.axis.background:SetTexture(0.12,0.16,0.28,1);
                end
                if ( sheet.isInteractive or sheet.columns[cellIndex].interactive ) then
                    row.axis:SetScript("OnMouseDown", function(caller, event) sheet:StartSelect({row=true, index=index}, event); end);
                    row.axis:SetScript("OnMouseUp", function(caller, event) sheet:EndSelect({row=true, index=index}, event); end);
                    row.axis:SetScript("OnEnter", function(caller, event) sheet:UpdateSelect({row=true, index=index}); end);
                    row.axis:SetScript("OnLeave", function(caller, event) sheet:UpdateSelect({row=true, index=index}); end);
                end
            end
            row.axis.label:SetText(index .. ": ");
            row.axis.label:Show();
            row.axis:SetHeight(sheet.rowHeight);
            row.axis:SetWidth(35);
            row.axis:Show();
            row.axis:SetPoint("TOPLEFT", row.frame, "TOPLEFT", offsetX, 0);
            offsetX = offsetX + 35 + sheet.cellSpacing;
        end

        for k, cellIndex in pairs(cols) do
            f = f + 1;
            local cell = row.cells[cellIndex];
            cell.l = {cellIndex, index};
            if ( not sheet.columns[cellIndex].hidden ) then
                if ( cell.frame == nil ) then
                    cell.frame = LibSpreadsheet:CreateFrame("Button", nil, row.frame);
                    cell.frame.icon:SetPoint("TOPLEFT", cell.frame, "TOPLEFT", (sheet.cellPadding), 0);
                    cell.frame.icon:SetTexCoord(0, 1, 0, 1);
                    cell.frame.label:SetPoint("TOPLEFT", cell.frame.icon, "TOPRIGHT", (sheet.cellPadding), -(sheet.cellPadding));
                    cell.frame.label:SetPoint("BOTTOMRIGHT", cell.frame, "BOTTOMRIGHT", -(sheet.cellPadding), (sheet.cellPadding));
                    cell.frame.sheet = sheet;
                    cell.frame.label:Show();
                    cell.frame.cell = cell;
                    cell.frame.overlay:SetTexture(0.3,0.2,1,0.25);
                    cell.u = true;
                end
                if ( cell.u ) then
                     if ( cell.i ) then
                       cell.frame.icon:SetTexture(cell.i);
                        if ( cell.t ) then
                            cell.frame.icon:SetTexCoord(cell.t[1], cell.t[2], cell.t[3], cell.t[4]);
                        end
                        cell.frame.icon:SetHeight(sheet.rowHeight);
                        cell.frame.icon:SetWidth(sheet.rowHeight);
                        cell.frame.icon:Show();
                    else
                        cell.frame.icon:SetTexture(nil);
                        cell.frame.icon:Hide();
                        cell.frame.icon:SetHeight(0.1);
                        cell.frame.icon:SetWidth(0.1);
                    end
                    cell.frame:SetWidth(sheet.columns[cellIndex].colwidth);
                    cell.frame:SetHeight(sheet.rowHeight);
                    cell.frame.column = cellIndex;
                    cell.frame.row = index;
                    cell.frame.label:SetJustifyH(sheet.columns[cellIndex].justify or "LEFT");
                    if ( cell.c ) then
                        cell.frame.label:SetTextColor((cell.c.r or cell.c[1]) or sheet.columns[cellIndex].c[1], (cell.c.g or cell.c[2]) or sheet.columns[cellIndex].c[2], (cell.c.b or cell.c[3]) or sheet.columns[cellIndex].c[3], 1);
                    else
                        cell.frame.label:SetTextColor(sheet.columns[cellIndex].c[1], sheet.columns[cellIndex].c[2], sheet.columns[cellIndex].c[3], 1);
                    end
                    if ( cell.b ) then
                        cell.frame.background:SetTexture(cell.b[1], cell.b[2], cell.b[3], cell.b[4] or 1);
                    else
                        cell.frame.background:SetTexture(sheet.columns[cellIndex].b[1], sheet.columns[cellIndex].b[2], sheet.columns[cellIndex].b[3], sheet.columns[cellIndex].b[4] or 1);
                    end
                    if ( sheet.isInteractive or sheet.columns[cellIndex].interactive ) then
                        cell.frame:SetScript("OnMouseDown", function(caller, event) sheet:StartSelect(cell.frame, event); end);
                        cell.frame:SetScript("OnMouseUp", function(caller, event) sheet:EndSelect(cell.frame, event); end);
                        cell.frame:SetScript("OnEnter", function(caller, event) sheet:UpdateSelect(cell.frame, event); end);
                        cell.frame:SetScript("OnDoubleclick", function(caller, event) sheet:ShowEditBox(cell.frame); end);
						cell.frame:SetScript("OnClick", function(caller, event)
							local x = self.callbacks['OnClick'] or sheet.callbacks['OnClick'];
							if ( type(x) == "function" ) then
								x(cell);
							end
						end);

                        cell.frame:SetScript("OnReceiveDrag", function(caller, event) sheet:ReceiveDrag(cell); end);
					else
						cell.frame:SetScript("OnEnter", function(caller, event)
							local x = self.callbacks['OnEnter'] or sheet.callbacks['OnEnter'];
							if ( type(x) == "function" ) then
								x(cell);
							end
						end);
						cell.frame:SetScript("OnLeave", function(caller, event)
							local x = self.callbacks['OnLeave'] or sheet.callbacks['OnLeave'];
							if ( type(x) == "function" ) then
								x(cell);
							end
						end);
                    end
                    if ( sheet.columns[cellIndex].onClick ~= nil ) then
                        local func = sheet.columns[cellIndex].onClick;
                        cell.frame:SetScript("OnClick", function(caller, event) func(cell.id, cell.data, cell.frame); end);
                    end
                    if ( sheet.columns[cellIndex].type == "number" or cell.t == "number" ) then
                        cell.frame.label:SetJustifyH("RIGHT");
                        cell.frame.label:SetFontObject(self.numberFont);
                    elseif ( sheet.columns[cellIndex].type == "currency" or cell.t == "currency" ) then
                        cell.frame.label:SetJustifyH("RIGHT");
                        cell.frame.label:SetFontObject(self.numberFont);
                    else
                        cell.frame.label:SetFontObject(self.stringFont);
                    end
                end
                cell.frame:ClearAllPoints();
                cell.frame:SetWidth(sheet.columns[cellIndex].colwidth);
                cell.frame:SetHeight(sheet.rowHeight);
                cell.frame:SetPoint("TOPLEFT", row.frame, "TOPLEFT", offsetX, 0);
                cell.frame.label:SetText(cell.text);
                cell.frame:Show();
                offsetX = offsetX + sheet.columns[cellIndex].colwidth + sheet.cellSpacing;
            end
        end
        row.frame:SetWidth(offsetX);
    end
    self.sheetSelector:Hide();
    self.scrollFrame:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", -16, 16);
    if ( self.showSelector == true ) then
        self:Leaf(0);
        self.scrollFrame:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", -16, 64);
        self.sheetSelector:Show();
    end
end

function LibSpreadsheet:SetCellSpacing(size)
    if ( type(size) ~= "number" ) then error(("%s: Error in setting cell spacing; Expected nuber, got %s!"):format(SPREADSHEET, type(number))); end
    self.cellSpacing = number;
end

function LibSpreadsheet:SetCellPadding(size)
    if ( type(size) ~= "number" ) then error(("%s: Error in setting cell padding; Expected nuber, got %s!"):format(SPREADSHEET, type(number))); end
    self.cellPadding = number;
end

function LibSpreadsheet:SetInteractive(toggle)
    if ( type(toggle) ~= "boolean" ) then error(("%s: Error in setting interactive mode; Expected boolean, got %s!"):format(SPREADSHEET, type(toggle))); end
    self.isInteractive = toggle;
end

function LibSpreadsheet:SetContextFunction(func)
    if ( type(func) ~= "function" ) then error(("%s: Error in setting context function; Expected function, got %s!"):format(SPREADSHEET, type(func))); end
    self.contextFunction = func;
end

function LibSpreadsheet:Freeze(toggle, col, row)
    if ( toggle == false ) then self.freezePoint = nil;
    else self.freezePoint = {col, row};
    end
end

function LibSpreadsheet:SetColorRange(column, ...)
    column = self:ExtractLocation(column);
    if ( self.columns[column] == nil ) then error(("%s: Error while setting color range for column %s: No such column!"):format(SPREADSHEET, LibSpreadsheet.cols[column])); end
    self.columns[column].colorRange = {};
    for i = 1, select("#", ...) do
        local color = select(i, ...);
        table.insert(self.columns[column].colorRange, color);
    end
end


function LibSpreadsheet:Leaf(direction)
    local c = 1;
    for k, v in pairs(self.sheets) do
        if ( v.title == self.selectedSheet.title ) then
            c = k;
            break;
        end
    end
    if ( direction == 1 ) then
        c = c + 1;
        if ( self.sheets[c] ~= nil ) then
            self.selectedSheet = self.sheets[c];
        end
    elseif ( direction == -1 ) then
        c = c - 1;
        if ( self.sheets[c] ~= nil ) then
            self.selectedSheet = self.sheets[c];
        end
    end
    if ( c < 2 ) then
        self.prevSheet:Disable();
    else
        self.prevSheet:Enable();
    end
    if ( c == table.maxn(self.sheets) ) then
        self.nextSheet:Disable();
    else
        self.nextSheet:Enable();
    end
    self.sheetSelectorText:SetText(self.title .. ": " .. self.selectedSheet.title);
    self.verticalScrollbar:SetValue(0);
end

function LibSpreadsheet:SetVisibleSelection(fromCol, fromRow, toCol, toRow)
    if ( type(fromCol) == "number" ) then
        self.selectStartColumn = fromCol;
        self.selectStartRow = fromRow;
    elseif ( type(fromCol) == "string" ) then
        local c, r = self:ExtractLocation(fromCol);
        if ( type(r) == "number" ) then
            self.selectStartColumn = c;
            self.selectStartRow = r;
            toRow = toCol;
            toCol = fromRow;
        else
            self.selectStartColumn = c;
            self.selectStartRow = fromRow;
        end
    end
    if ( type(toCol) == "number" ) then
        self.selectEndColumn = toCol;
        self.selectEndRow = toRow;
    elseif ( type(toCol) == "string" ) then
        local c, r = self:ExtractLocation(toCol);
        if ( type(r) == "number" ) then
            self.selectEndColumn = c;
            self.selectEndRow = r;
        else
            self.selectEndColumn = c;
            self.selectEndRow = toRow;
        end
    end
    self.selecting = true;
    self:UpdateSelect(nil);
    self.selecting = false;
end


function LibSpreadsheet:StartSelect(caller, event)
    if ( event == "LeftButton" ) then
        self.selecting = true;
        if ( IsShiftKeyDown() ) then
            self.selectEndColumn = caller.column;
            self.selectEndRow = caller.row;
        else
            self.selectStartColumn = caller.column;
            self.selectStartRow = caller.row;
        end
        if ( caller.row == true ) then
            self.selectStartRow = caller.index;
            self.selectStartColumn = 1;
            self.selectEndColumn = #self.columns;
        end
        if ( caller.column == true ) then
            self.selectStartColumn = caller.index;
            self.selectStartRow = 1;
            self.selectEndRow = #self.rows;
        end
        self:UpdateSelect(caller);
    elseif ( event == "RightButton" and caller.cell ) then
        --print(self.selectStartColumn, self.selectStartRow, self.selectEndColumn, self.selectEndRow);
        if ( caller.cell.x == true ) then
            self.selecting = true;
            if ( type(self.parent().contextFunction) == "function" ) then
                self.parent().contextFunction(caller);
            end
        else
            self.selectStartColumn = nil;
            self.selectStartRow = nil;
            self.selectEndColumn = nil;
            self.selectEndRow = nil;
            self:UpdateSelect(nil);
        end
    end
end

function LibSpreadsheet:EndSelect(caller, event)
    if ( event == "LeftButton" ) then
        self.selecting = false;
        if not ( self.selectStartColumn == self.selectEndColumn and self.selectStartRow == self.selectEndRow ) then
            if ( self.callbacks['OnSelectionChange'] ~= nil ) then
                if ( type(self.callbacks['OnSelectionChange']) == "function" ) then
                    (self.callbacks['OnSelectionChange'])(math.min(self.selectStartColumn, self.selectEndColumn), math.min(self.selectStartRow, self.selectEndRow), math.max(self.selectStartColumn, self.selectEndColumn), math.max(self.selectStartRow, self.selectEndRow));
                end
            end
        end
    end
end

function LibSpreadsheet:UpdateSelect(caller)
    GameTooltip:Hide();
    local rowTable = self.rows;
    if ( self.hasGroups or self.hasFilters ) then rowTable = self.rowHeap; end
    if ( IsMouseButtonDown("LeftButton") or IsMouseButtonDown("RightButton") ) then
        for x = 1, table.maxn(rowTable) do
            for y = 1, table.maxn(self.columns) do
                rowTable[x].cells[y].x = false;
             --   print("f: ", y, x);
            end
        end
    end
    if ( IsMouseButtonDown("LeftButton") ) then
        if ( caller ~= nil ) then
            self.selectEndColumn = caller.column;
            self.selectEndRow = caller.row;
            if ( caller.row == true ) then
                self.selectEndColumn = #self.columns;
                self.selectEndRow = caller.index;
            end
            if ( caller.column == true ) then
                self.selectEndRow = #self.rows;
                self.selectEndColumn = caller.index;
            end
        end
        if ( self.selectEndRow == nil ) then self.selectEndRow  = self.selectStartRow ; end
        if ( self.selectStartRow ~= nil ) then
            for x = math.min(self.selectStartRow, self.selectEndRow), math.max(self.selectStartRow, self.selectEndRow) do
                for y = math.min(self.selectStartColumn, self.selectEndColumn), math.max(self.selectStartColumn, self.selectEndColumn) do
                    if ( rowTable[x] and rowTable[x].cells[y] ) then
                        rowTable[x].cells[y].x = true;
             --           print("t: ", y, x);
                    end
                end
            end
        end
    end
    if ( IsMouseButtonDown("LeftButton") or caller == nil) then
        for x = 1, table.maxn(rowTable) do
            for y = 1, table.maxn(self.columns) do
                local cell = rowTable[x].cells[y];
                if ( cell.x == true and ( cell.frame ) ) then cell.frame.overlay:Show();
                elseif ( cell.frame ) then cell.frame.overlay:Hide();
                end
            end
        end
    end
    if ( caller ~= nil and (caller.cell or {}).t == "link" ) then
        local t, l = (caller.cell.data or ""):match("(%l+):(%d+)");
        if ( t and l ) then
            if ( t == "spell" or t == "item" ) then
                GameTooltip:SetOwner(caller, "ANCHOR_TOPLEFT");
				GameTooltip:SetHyperlink(caller.cell.data);
                GameTooltip:Show();
            end
        end
    end
end

function LibSpreadsheet:GetSelectedCells(max)
 --   print(self.selectStartColumn, self.selectStartRow, self.selectEndColumn, self.selectEndRow);
    local rowTable = self.rows;
    local tbl = {};
    local i = 0;
    if ( self.hasGroups or self.hasFilters ) then rowTable = self.rowHeap; end
    if ( self.selectEndRow == nil ) then self.selectEndRow  = self.selectStartRow ; end
    if ( self.selectStartRow ~= nil ) then
        for x = math.min(self.selectStartRow, self.selectEndRow), math.max(self.selectStartRow, self.selectEndRow) do
         --   print("row: " .. x);
            if ( i >= (max or 0) and max ) then break; end
            for y = math.min(self.selectStartColumn, self.selectEndColumn), math.max(self.selectStartColumn, self.selectEndColumn) do
        --        print("col: " .. y);
                if ( i >= (max or 0) and max ) then break; end
           --     print ("a: ", rowTable[x].cells[y].x);
                if ( rowTable[x] and rowTable[x].cells[y] and rowTable[x].cells[y].x == true ) then
                    i = i + 1; --print(999, x,y);
                    table.insert(tbl, rowTable[x].cells[y]);
                end
            end
        end
    end
    return tbl;
end

function LibSpreadsheet:GetSelectedRows()
    local rowTable = self.rows;
    local tbl = {};
    if ( self.hasGroups or self.hasFilters ) then rowTable = self.rowHeap; end
    if ( self.selectEndRow == nil ) then self.selectEndRow  = self.selectStartRow ; end
    if ( self.selectStartRow ~= nil ) then
        for x = math.min(self.selectStartRow, self.selectEndRow), math.max(self.selectStartRow, self.selectEndRow) do
            table.insert(tbl, x);
        end
    end
    return tbl;
end

function LibSpreadsheet:GetSelectedCols()
    local rowTable = self.rows;
    local tbl = {};
    if ( self.hasGroups or self.hasFilters ) then rowTable = self.rowHeap; end
    if ( self.selectEndRow == nil ) then self.selectEndRow  = self.selectStartRow ; end
    if ( self.selectStartRow ~= nil ) then
        for x = math.min(self.selectStartColumn, self.selectEndColumn), math.max(self.selectStartColumn, self.selectEndColumn) do
            table.insert(tbl, x);
        end
    end
    return tbl;
end




function LibSpreadsheet:HideColumn(...)
    for i = 1, select("#", ...) do
        local column = self:ExtractLocation(select(i, ...));
        if ( self.columns[column] ~= nil ) then
            self.columns[column].hidden = true;
        end
    end
end

function LibSpreadsheet:ShowColumn(...)
    for i = 1, select("#", ...) do
        local column = self:ExtractLocation(select(i, ...));
        if ( self.columns[column] ~= nil ) then
            self.columns[column].hidden = false;
        end
    end
end

function LibSpreadsheet:SetSheetCallback(event, func)
    local found = false;
    for k,v in pairs(LibSpreadsheet.callbackEvents) do
        if ( v == event ) then
            found = true;
            break;
        end
    end
    if ( found == true ) then
        if ( type(func) == "function" ) then
            self.callbacks[event] = func;
        else
            error(("%s: Error in SetCallback(): expected function, got %s!"):format(SPREADSHEET, type(func)));
        end
    else
        error(("%s: Error in SetCallback(): No such event, '%s'!"):format(SPREADSHEET, event));
    end
end

function LibSpreadsheet:ShowEditBox(cellFrame)
    local ret = true;
    local box = self.parent().editbox;
    box.clink = ChatFrame_OnHyperlinkShow;
    ChatFrame_OnHyperlinkShow = function(self, link, text, button) box:SetText(link); end
    if ( self.parent().editbox:IsVisible() ) then
        self.parent().editbox:Hide();
    end
    if ( self.callbacks['OnUserInputRequested'] ~= nil ) then
        if ( type(self.callbacks['OnUserInputRequested']) == "function" ) then
            ret = (self.callbacks['OnUserInputRequested'])(cellFrame.col, cellFrame.row, cellFrame.cell.id, cellFrame.cell.data);
        end
    end
    if ( ret ) then
        if ( type(cellFrame.cell.data) ~= "boolean" ) then
            self.parent().editbox:SetText(string.format("%s", cellFrame.cell.data or ""));
        end
        self.parent().editbox:ClearAllPoints();
        self.parent().editbox.caller = cellFrame;
        self.parent().editbox:SetAllPoints(cellFrame);
        self.parent().editbox:SetFrameLevel("999");
        self.parent().editbox:SetFrameStrata("FULLSCREEN_DIALOG");
        self.parent().editbox:Show();
        cellFrame:Hide();
    end
end

function LibSpreadsheet:SaveEditBox(cellFrame, text)
    local ret = true;
    ChatFrame_OnHyperlinkShow = self.parent().editbox.clink;
    if ( self.callbacks['OnUserInputProcessed'] ~= nil ) then
        if ( type(self.callbacks['OnUserInputProcessed']) == "function" ) then
            ret = (self.callbacks['OnUserInputProcessed'])(cellFrame.col, cellFrame.row, cellFrame.cell.id, cellFrame.cell.data, text);
        end
    end
    if ( ret ) then
        if ( cellFrame.cell.t == "number" or self.columns[cellFrame.column].type == "number" ) then
            if ( tonumber(text) ~= nil ) then text = tonumber(text); end
        end
        cellFrame.cell.MathFunction = nil;
        cellFrame.cell.MathData = nil;
        cellFrame.cell.data = text;
        cellFrame.cell.u = true;
        self.parent():Render_Update();
    end
    self.parent().editbox:ClearAllPoints();
    self.parent().editbox:SetText("");
end

function LibSpreadsheet:SetStyle(style)
    if ( style == "sheet" ) then self.style = "SHEET";
    else self.style = "LIST";
    end
end

function LibSpreadsheet:ReceiveDrag(cell)
    if ( self.isInteractive ) then
        local t, i, j = GetCursorInfo();
        ClearCursor();
        if ( t == "item" ) then
            cell.data = "item:" .. (i or 1);
        elseif ( t == "spell" ) then
            local link = GetSpellLink(i, j);
            cell.data = link;
        elseif ( t == "money" ) then
            cell.data = i;
        end
        cell.u = true;
        self.parent():Render_Real();
    end
end

--[[
LibSpreadsheet-1.0 Math functions
]]--

function LibSpreadsheet:RunMath(Math)
    return self:ParseMath(Math, true);
end
function LibSpreadsheet:ParseMath(Math, execute)
    local result = nil;
    local i = 0;
    local n = 1;
    local c;
    local f = "";
    local fc = "";
    local args = "";
    local chunks = {};
    local from = nil;
    while i <= Math:len() do
        i = i + 1;
        c = Math:sub(i,i):upper();
        if ( c == ":" ) then
            if ( f:len() > 0 ) then
                from = f .. fc;
                f = "";
                fc = "";
                args = "";
            end
        end
        if ( c == " " or c == "\t" ) then
            if ( f:len() > 0 and from ~= nil ) then
                table.insert(chunks, {type="func", val='LIST', args={from, f..fc}});
                from = nil;
                f = "";
                fc = "";
                args = "";
            elseif ( f:len() > 0 ) then
                if ( fc ~= "" ) then
                    table.insert(chunks, {type="cell", val=f, args=fc});
                else
                    table.insert(chunks, {type="func", val='LIST', args={f}});
                end
                f = "";
                fc = "";
                args = "";
            elseif ( fc:len() > 0 ) then
                table.insert(chunks, {type="func", val='NUM', args={fc}});
                f = "";
                fc = "";
                args = "";
            end
        elseif ( c == "+" or c == "-" or c == "/" or c == "*" or c == "=" ) then
            if ( f:len() > 0 ) then
                table.insert(chunks, {type="cell", val=f, args=fc});
                f = "";
                fc = "";
                args = "";
            elseif ( fc:len() > 0 ) then
                table.insert(chunks, {type="func", val='NUM', args={fc}});
                f = "";
                fc = "";
                args = "";
            end
            table.insert(chunks, {type="control", val=c, args=nil});
        elseif ( (c >= "A" and c <= "Z") or c == [["]]) then f = f .. c;
        elseif ( c == "(" or c == "{" ) then
            local intro, extro = [[(]], [[)]];
            if ( c == "{" ) then intro, extro = [[{]], [[}]]; end
            local p = 0;
            local si = i;
            local spos = 2;
            local epos = 0;
            local argList = {};
            while si <= Math:len() do
                epos = epos + 1;
                local c = Math:sub(si,si);
                args = args .. c;
                if ( c == intro) then p = p + 1; end
                if ( c == extro ) then p = p - 1; end
                if ( c == "," and p == 1 ) then
                    table.insert(argList, args:sub(spos, epos-1));
                    spos = epos + 1;
                end
                if ( p == 0 ) then
                    break;
                end
                si = si + 1;
            end
            if ( p ~= 0 ) then error("Expected ')' before <eol> in Math");
            else
                i = si
                if ( spos ~= args:len() ) then
                    table.insert(argList, args:sub(spos, epos-1));
                end
                table.insert(chunks, {type="func", val=f, args=argList});
                f = "";
                fc = "";
                args = "";
            end
        elseif ( c >= "0" and c <= "9" or c == ".") then
            fc = fc .. c;
        elseif ( c == "$" ) then
        else
        end
    end
    if ( f:len() > 0 and from ~= nil ) then
        table.insert(chunks, {type="func", val='LIST', args={from, f..fc}});
        from = nil;
        f = "";
        fc = "";
        args = "";
    elseif ( f:len() > 0) then
        if ( fc ~= "" ) then
                    table.insert(chunks, {type="cell", val=f, args=fc});
                else
                    table.insert(chunks, {type="func", val='LIST', args={f}});
                end
        f = "";
        fc = "";
        args = "";
    elseif ( fc:len() > 0 ) then
        table.insert(chunks, {type="func", val='NUM', args={fc}});
        f = "";
        fc = "";
        args = "";
    end
    local fstring = "";
    for k, func in pairs(chunks) do
        if ( func.type == "control" ) then
            if ( func.val == "=" ) then func.val = "=="; end
                fstring = fstring .. " " .. func.val .. " ";
        end
        if ( func.type == "cell" ) then
            fstring = fstring .. "_G.LibSpreadsheetTemp:GetValue('" .. func.val .. "', " .. func.args .. ") ";
        end
        if ( func.type == "func" ) then
            local argsCompiled = {};
            local realFunc = {};
            for k, entry in pairs (LibSpreadsheet.MathFuncs) do
                if ( func.val == entry.func ) then
                    realFunc = entry;
                    break;
                end
            end
            if ( realFunc.internal == nil ) then
                error("No such Math function: " .. func.val .. "!");
            end
            if ( realFunc.internal == false ) then
                for k, arg in pairs(func.args) do
                    if ( arg:len() > 1 and tonumber(arg) == nil and arg:sub(1,1) ~= '"') then
                        table.insert(argsCompiled, self:ParseMath(arg, false));
                    elseif ( arg:len() == 1 and arg >= "A" and arg <= "Z" ) then
                        table.insert(argsCompiled, "_G.LibSpreadsheetTemp:ListCellsMath('" .. arg .. "')");
                    else
                        table.insert(argsCompiled, arg);
                    end
                end
            else
                if ( realFunc.unitFunc ) then
                    if ( #func.args == 0 or func.args[1] == "" ) then table.insert(func.args, 1, "player"); end
                    if ( func.prefix ) then table.insert(func.args, 1, func.prefix); end
                    if ( func.suffix ) then table.insert(func.args, func.suffix); end
                end
                for k, arg in pairs(func.args) do
                    if ( arg:len() > 1 and tonumber(arg) ~= nil ) then
                        table.insert(argsCompiled, self:ParseMath(arg, false));
                    elseif ( type(arg) == "string" or type(arg) == "number" or type(arg) == "boolean" ) then
                        table.insert(argsCompiled, '"' .. arg .. '"');
                    end
                end
            end
            fstring = fstring .. realFunc.caller .. "(" .. table.concat(argsCompiled, ", ") .. ")";
        end
    end
    _G.LibSpreadsheetTemp = self;
    if ( not execute ) then
        return fstring;
    else
        result, err = loadstring("return (" ..fstring .. ") ");
        --print(fstring);
        if ( err ) then
            error(err);
        else
            return result();
        end
    end
end

_G.LibSpreadsheetMath = {};

function LibSpreadsheetMath:Math_If(eval, iftrue, iffalse)
    if ( eval ) then
        return iftrue;
    else
        return iffalse;
    end
end

function LibSpreadsheetMath:Math_And(expa, expb)
    return (expa and expb);
end

function LibSpreadsheetMath:Math_Or(expa, expb)
    return (expa or expb);
end


function LibSpreadsheetMath:Math_Sum(...)
    local val = 0;
    for k, v in pairs({select(1, ...)}) do
        val = val + (tonumber(v) or 0);
    end
    return val;
end

function LibSpreadsheetMath:Math_Average(...)
    local val = 0;
    local num = 0;
    for k, v in pairs({select(1, ...)}) do
        val = val + (tonumber(v) or 0);
        if ( tonumber(v) ~= nil ) then
            num = num + 1;
        end
    end
    return val/num;
end

function LibSpreadsheetMath:Math_Mode(...)
    local vals = {select(1,...)};
    local mode = {};
    table.sort(vals);
    for k, v in pairs(vals) do
        mode[v] = (mode[v] or 0) + 1;
    end
    local n = 0;
    local m = 0;
    for k, v in pairs(mode) do
        if ( v > n ) then n = v; m = k; end
    end
    return m;
end


function LibSpreadsheetMath:Math_Median(...)
    local vals = {select(1,...)};
    table.sort(vals);
    return vals[math.floor((#vals/2) + 0.5)] or 0;
end

function LibSpreadsheetMath:Math_Large(k, ...)
    local vals = {select(1,...)};
    table.sort(vals);
    return vals[#vals-(k-1)] or 0;
end

function LibSpreadsheetMath:Math_Small(k, ...)
    local vals = {select(1,...)};
    table.sort(vals);
    return vals[k] or 0;
end

function LibSpreadsheetMath:Math_SumIf(statement, ...)
    local vals = {select(1,...)};
	local ret = 0;
	if ( type(statement) == "string" ) then
		local i = 1;
		if ( statement:sub(2,2) == "=" ) then i = 2; end
		local sign, number = statement:sub(1,i), tonumber(statement:sub(i+1));
		for k, v in pairs(vals) do
			if ( sign == '=' and v == number ) then ret = ret + v; end
			if ( sign == '>' and v > number ) then ret = ret + v; end
			if ( sign == '<' and v < number ) then ret = ret + v; end
			if ( sign == '>=' and v >= number ) then ret = ret + v; end
			if ( sign == '<=' and v <= number ) then ret = ret + v; end
			if ( sign == '!=' and v ~= number ) then ret = ret + v; end
		end
	end
	return ret;
end

function LibSpreadsheetMath:Math_CountIf(statement, ...)
    local vals = {select(1,...)};
	local ret = 0;
	if ( type(statement) == "string" ) then
		local i = 1;
		if ( statement:sub(2,2) == "=" ) then i = 2; end
		local sign, number = statement:sub(1,i), tonumber(statement:sub(i+1));
		for k, v in pairs(vals) do
			if ( sign == '=' and v == number ) then ret = ret + 1; end
			if ( sign == '>' and v > number ) then ret = ret + 1; end
			if ( sign == '<' and v < number ) then ret = ret + 1; end
			if ( sign == '>=' and v >= number ) then ret = ret + 1; end
			if ( sign == '<=' and v <= number ) then ret = ret + 1; end
			if ( sign == '!=' and v ~= number ) then ret = ret + 1; end
		end
	end
	return ret;
end

function LibSpreadsheetMath:Math_Sign(val)
    return ( val > 0 and 1 ) or ( val < 0 and -1 ) or 0;
end

function LibSpreadsheetMath:Math_Count(...)
	return select("#", ...) or 0;
end

function LibSpreadsheetMath:Math_Logarithm(num, base)
    return (math.log(num) / math.log(base or 10));
end

function LibSpreadsheetMath:Math_Unique(...)
    local tmp = {};
    local ret = {};
    for k, v in pairs({select(1, ...)}) do
        if ( tmp[v] == nil ) then
            tmp[v] = 1;
            table.insert(ret, v);
        end
    end
    return unpack(ret);
end

function LibSpreadsheetMath:Math_StdDev(...)
    local val = 0;
    local population = select("#", ...);
    for k, v in pairs({select(1, ...)}) do
        val = val + (tonumber(v) or 0);
    end
    local mean = val / population;
    local val = 0;
    for k, v in pairs({select(1, ...)}) do
        val = val + math.pow( ( (tonumber(v) or 0) - mean), 2);
    end
    val = val /(population-1);
    return math.sqrt(val);
end

function LibSpreadsheetMath:Math_Round(num, mul)
    return ( math.floor((num/(mul or 1))+0.5) * (mul or 1));
end

function LibSpreadsheetMath:Math_Floor(num, mul)
    return ( math.floor((num/(mul or 1))) * (mul or 1));
end

function LibSpreadsheetMath:Math_Ceil(num, mul)
    return ( math.ceil((num/(mul or 1))) * (mul or 1));
end

--[[ TEST SCRIPT ]] --

function LibSpreadTest()
    local lss = LibStub("LibSpreadsheet-1.0", true);                    -- Load the lib
    local book = lss:Book("LibSpreadsheet examples");                   -- Make a new book
    local sheet = book:Add("Food!");                                 -- Add a sheet to the book
    book:StrictMode(true);
    sheet.isInteractive = true;
    book:ShowSelector(true);
    sheet:AddColumn(
        {name="Name", sort=true},
        {name="Type", sort = true},
        {name="Is healthy", type="boolean"},
        {name="Calories", type="number"},
        {name="Some other column", type="string"},
        {name="Some final column", type="string"}
        );  -- Set some headers
    local i;
    sheet:SetRow(sheet:AddRow({data="Apple", icon=[[Interface\LFGFrame\LFGRole]], texcoords={0.25,0.50,0,1}}, "Fruit", true,12), {background={0.3,0.8,0.2,0.5}});
    sheet:SetRow(sheet:AddRow({data="Peach", icon=[[Interface\Icons\Inv_misc_food_42]]}, "Fruit", true,12), {background={0.3,0.8,0.2,0.5}});
    sheet:SetRow(sheet:AddRow({data="Banana", icon=[[Interface\Icons\Inv_misc_food_24]]}, "Fruit", true,34), {background={0.3,0.8,0.2,0.5}});
    sheet:SetRow(sheet:AddRow({data="Orange", icon=[[Interface\Icons\Inv_misc_food_41]]}, "Fruit", true,47), {background={0.3,0.8,0.2,0.5}});
    sheet:SetRow(sheet:AddRow({data="Ham", icon=[[Interface\Icons\Inv_misc_food_13]]}, "Meat", true, 48), {background={0.8,0.4,0.2,0.5}});
    sheet:SetRow(sheet:AddRow({data="Salmon", icon=[[Interface\Icons\Inv_misc_food_75]]}, "Meat", true, 83), {background={0.5,0.6,0.2,0.5}});
    sheet:SetRow(sheet:AddRow({data="T-bone Steak", icon=[[Interface\Icons\Inv_misc_food_70]]}, "Meat", false), {background={0.8,0.7,0.2,0.5}});
    sheet:SetRow(sheet:AddRow({data="Sausage", icon=[[Interface\Icons\Inv_misc_food_66]]}, "Meat", false), {background={0.8,0.3,0.2,0.5}});
    sheet:SetRow(sheet:AddRow({data="Croissant", icon=[[Interface\Icons\Inv_misc_food_32]]}, "Bread", false), {background={0.9,0.2,0.2,0.5}});
    sheet:SetRow(sheet:AddRow({data="Bagel", icon=[[Interface\Icons\Inv_misc_food_34]]}, "Bread", true), {background={0.7,0.6,0.2,0.5}});
    sheet:SetRow(sheet:AddRow({data="Wholegrain Bread", icon=[[Interface\Icons\Inv_misc_food_95_grainbread]]}, "Bread", true), {background={0.4,0.7,0.2,0.5}});
    sheet:SetRow(sheet:AddRow({data="Cinnamon Roll", icon=[[Interface\Icons\Inv_misc_food_73cinnamonroll]]}, "Bread", false, 100, "moooooooooo"), {background={0.9,0.3,0.2,0.5}});
    book:EnableMaths(true);
    if ( UIParent ) then
        local frame = book:Render();                                        -- Create the UI
        local window = LibSpreadsheet:CreateFrame("Frame", nil, UIParent, "DialogBoxFrame");
        window:SetPoint("CENTER", UIParent, "CENTER", 0, 0);
        window:SetWidth(600);
        window:SetHeight(350);
        window:RegisterForDrag("LeftButton");
        window:SetScript("OnDragStart",function()  window:StartMoving(); end);
        window:SetScript("OnDragStop", function()  window:StopMovingOrSizing(); end);
        window:SetMovable(true);
        window:EnableMouse(true);
        frame:SetParent(window);
        frame:SetPoint("TOPLEFT", window, "TOPLEFT", 20, -20);
        frame:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -20, 50);
        frame:Show();
        window:Show();
    end
end

if ( dofile ) then
    LibSpreadTest();
end

do
    local eventFrame = CreateFrame("Frame", nil);
    eventFrame:RegisterEvent("PLAYER_LOGOUT");
    eventFrame:SetScript("OnEvent",
        function(caller, event) print(caller, event);
            if ( event == "PLAYER_LOGOUT" ) then
                for key, val in pairs(LibSpreadsheet.books) do
                    if (val and val.Close) then
                        val:Close();
                    end
                end
            end
        end);
    eventFrame:SetParent(UIParent);
    eventFrame:Show();
end
