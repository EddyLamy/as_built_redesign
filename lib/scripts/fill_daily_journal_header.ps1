param(
    [Parameter(Mandatory = $true)]
    [string]$WorkbookPath,

    [Parameter(Mandatory = $true)]
    [string]$HeaderJsonBase64
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $WorkbookPath)) {
    throw "Workbook not found: $WorkbookPath"
}

$resolvedWorkbookPath = (Resolve-Path -LiteralPath $WorkbookPath).Path

$json = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($HeaderJsonBase64))
$header = $json | ConvertFrom-Json

$excel = $null
$workbook = $null

function Clear-CellValue {
    param(
        $Worksheet,
        [string]$Address
    )

    try {
        $Worksheet.Range($Address).Value2 = ''
    }
    catch {
        throw "Failed clearing cell $Address. $($_.Exception.Message)"
    }
}

function Set-CellValue {
    param(
        $Worksheet,
        $Address,
        $Value,
        $NumberFormat = $null
    )

    if ($null -eq $Value -or $Value -eq '') {
        return
    }

    try {
        $range = $Worksheet.Range([string]$Address)
        $cellValue = $Value
        if ($Value -is [datetime]) {
            switch ([string]$NumberFormat) {
                'dd.mm.yyyy' { $cellValue = $Value.ToString('dd.MM.yyyy') }
                'dd/mm/yyyy' { $cellValue = $Value.ToString('dd/MM/yyyy') }
                default { $cellValue = $Value.ToString('yyyy-MM-dd') }
            }
            $range.NumberFormat = '@'
        }
        elseif ($null -ne $Value) {
            $cellValue = [string]$Value
        }
        $range.Value2 = $cellValue
    }
    catch {
        $valueType = if ($null -eq $Value) { 'null' } else { $Value.GetType().FullName }
        throw "Failed writing cell $Address with value type $valueType and value '$Value'. $($_.Exception.Message)"
    }
}

function Copy-WorksheetAfter {
    param(
        $SourceWorksheet,
        $AfterWorksheet
    )

    try {
        $missing = [System.Type]::Missing
        [void]$SourceWorksheet.GetType().InvokeMember(
            'Copy',
            [System.Reflection.BindingFlags]::InvokeMethod,
            $null,
            $SourceWorksheet,
            @($missing, $AfterWorksheet)
        )
    }
    catch {
        throw "Failed copying worksheet '$($SourceWorksheet.Name)'. $($_.Exception.Message)"
    }
}

function Get-UniqueWorksheetName {
    param(
        $Workbook,
        $CurrentWorksheet,
        [string]$DesiredName
    )

    $candidate = $DesiredName
    $suffix = 2

    while ($true) {
        $inUse = $false
        foreach ($sheet in $Workbook.Worksheets) {
            if ($sheet.Name -eq $CurrentWorksheet.Name) {
                continue
            }

            if ($sheet.Name -eq $candidate) {
                $inUse = $true
                break
            }
        }

        if (-not $inUse) {
            return $candidate
        }

        $candidate = "$DesiredName ($suffix)"
        $suffix++
    }
}

try {
    $excel = New-Object -ComObject Excel.Application
    $excel.Visible = $false
    $excel.DisplayAlerts = $false
    $excel.ScreenUpdating = $false

    $workbook = $excel.Workbooks.Open($resolvedWorkbookPath)
    $calendar = [System.Globalization.CultureInfo]::InvariantCulture.Calendar
    $weekRule = [System.Globalization.CalendarWeekRule]::FirstFourDayWeek
    $firstDay = [System.DayOfWeek]::Monday
    $journals = @($header.journals)

    if ($journals.Count -eq 0) {
        throw 'No Daily Journal records were provided for export.'
    }

    $visibleSheets = @()
    foreach ($worksheet in $workbook.Worksheets) {
        if ($worksheet.Visible -eq -1) {
            $visibleSheets += $worksheet
        }
    }

    if ($visibleSheets.Count -eq 0) {
        throw 'No visible Daily Journal template sheet was found.'
    }

    $templateSheet = $visibleSheets[0]

    for ($index = $visibleSheets.Count - 1; $index -ge 1; $index--) {
        $visibleSheets[$index].Delete()
    }

    $targetSheets = @($templateSheet)
    for ($sheetIndex = 1; $sheetIndex -lt $journals.Count; $sheetIndex++) {
        Copy-WorksheetAfter `
            -SourceWorksheet $templateSheet `
            -AfterWorksheet $workbook.Worksheets.Item($workbook.Worksheets.Count)
        $targetSheets += $workbook.Worksheets.Item($workbook.Worksheets.Count)
    }

    for ($sheetIndex = 0; $sheetIndex -lt $targetSheets.Count; $sheetIndex++) {
        $worksheet = $targetSheets[$sheetIndex]
        $journal = $journals[$sheetIndex]
        $journalDate = $null
        if ($journal.journalDate) {
            $journalDate = [datetime]::Parse($journal.journalDate)
            $sheetName = Get-UniqueWorksheetName `
                -Workbook $workbook `
                -CurrentWorksheet $worksheet `
                -DesiredName $journalDate.ToString('dd.MM.yyyy')
            $worksheet.Name = $sheetName
        }

        Set-CellValue -Worksheet $worksheet -Address 'B7' -Value $header.projectNo
        Set-CellValue -Worksheet $worksheet -Address 'I7' -Value $header.projectName
        Set-CellValue -Worksheet $worksheet -Address 'S7' -Value $journal.reportNo
        Set-CellValue -Worksheet $worksheet -Address 'S8' -Value $journal.initials
        $installationTeamCount = if ($null -ne $journal.installationTeamCount) {
            $journal.installationTeamCount
        }
        else {
            $header.installationTeamCount
        }

        $craneCrewCount = if ($null -ne $journal.craneCrewCount) {
            $journal.craneCrewCount
        }
        else {
            $header.craneCrewCount
        }

        Set-CellValue -Worksheet $worksheet -Address 'C10' -Value $installationTeamCount
        Set-CellValue -Worksheet $worksheet -Address 'H10' -Value $craneCrewCount

        for ($row = 15; $row -le 30; $row++) {
            Clear-CellValue -Worksheet $worksheet -Address "A$row"
            Clear-CellValue -Worksheet $worksheet -Address "B$row"
            Clear-CellValue -Worksheet $worksheet -Address "D$row"
            Clear-CellValue -Worksheet $worksheet -Address "L$row"
        }

        for ($row = 33; $row -le 39; $row++) {
            Clear-CellValue -Worksheet $worksheet -Address "A$row"
        }

        for ($row = 41; $row -le 53; $row++) {
            Clear-CellValue -Worksheet $worksheet -Address "A$row"
            Clear-CellValue -Worksheet $worksheet -Address "C$row"
            Clear-CellValue -Worksheet $worksheet -Address "E$row"
            Clear-CellValue -Worksheet $worksheet -Address "H$row"
            Clear-CellValue -Worksheet $worksheet -Address "J$row"
        }
        Clear-CellValue -Worksheet $worksheet -Address 'J54'

        for ($row = 59; $row -le 66; $row++) {
            Clear-CellValue -Worksheet $worksheet -Address "A$row"
            Clear-CellValue -Worksheet $worksheet -Address "D$row"
            Clear-CellValue -Worksheet $worksheet -Address "G$row"
            Clear-CellValue -Worksheet $worksheet -Address "I$row"
            Clear-CellValue -Worksheet $worksheet -Address "K$row"
            Clear-CellValue -Worksheet $worksheet -Address "L$row"
        }
        Clear-CellValue -Worksheet $worksheet -Address 'K67'

        if ($journalDate) {
            $week = $calendar.GetWeekOfYear($journalDate, $weekRule, $firstDay)
            Set-CellValue -Worksheet $worksheet -Address 'B8' -Value $week
            Set-CellValue -Worksheet $worksheet -Address 'I8' -Value $journalDate -NumberFormat 'dd.mm.yyyy'
        }

        if ($journal.remarks) {
            Set-CellValue -Worksheet $worksheet -Address 'A33' -Value $journal.remarks
        }

        $rows = @($journal.siteWorkProgress)
        for ($rowIndex = 0; $rowIndex -lt $rows.Count -and $rowIndex -lt 16; $rowIndex++) {
            $rowNumber = 15 + $rowIndex
            $rowData = $rows[$rowIndex]
            if ($null -eq $rowData) {
                continue
            }

            Set-CellValue -Worksheet $worksheet -Address "A$rowNumber" -Value $rowData.location
            Set-CellValue -Worksheet $worksheet -Address "B$rowNumber" -Value $rowData.category
            Set-CellValue -Worksheet $worksheet -Address "D$rowNumber" -Value $rowData.subCategory
            Set-CellValue -Worksheet $worksheet -Address "L$rowNumber" -Value $rowData.notes
        }

        $peopleHoursRows = @($journal.peopleHoursEntries)
        for ($rowIndex = 0; $rowIndex -lt $peopleHoursRows.Count -and $rowIndex -lt 13; $rowIndex++) {
            $rowNumber = 41 + $rowIndex
            $rowData = $peopleHoursRows[$rowIndex]
            if ($null -eq $rowData) {
                continue
            }

            Set-CellValue -Worksheet $worksheet -Address "A$rowNumber" -Value $rowData.initials
            Set-CellValue -Worksheet $worksheet -Address "C$rowNumber" -Value $rowData.startTime
            Set-CellValue -Worksheet $worksheet -Address "E$rowNumber" -Value $rowData.finishTime
            Set-CellValue -Worksheet $worksheet -Address "H$rowNumber" -Value $rowData.travellingTime
            Set-CellValue -Worksheet $worksheet -Address "J$rowNumber" -Value $rowData.manhours
        }

        if ($journal.totalManhours) {
            Set-CellValue -Worksheet $worksheet -Address 'J54' -Value $journal.totalManhours
        }

        $waitingRows = @($journal.waitingTimeEntries)
        for ($rowIndex = 0; $rowIndex -lt $waitingRows.Count -and $rowIndex -lt 8; $rowIndex++) {
            $rowNumber = 59 + $rowIndex
            $rowData = $waitingRows[$rowIndex]
            if ($null -eq $rowData) {
                continue
            }

            Set-CellValue -Worksheet $worksheet -Address "A$rowNumber" -Value $rowData.responsible
            Set-CellValue -Worksheet $worksheet -Address "D$rowNumber" -Value $rowData.company
            Set-CellValue -Worksheet $worksheet -Address "G$rowNumber" -Value $rowData.people
            Set-CellValue -Worksheet $worksheet -Address "I$rowNumber" -Value $rowData.totalHours
            Set-CellValue -Worksheet $worksheet -Address "K$rowNumber" -Value $rowData.manhours
            Set-CellValue -Worksheet $worksheet -Address "L$rowNumber" -Value $rowData.description
        }

        if ($journal.totalWaitingManhours) {
            Set-CellValue -Worksheet $worksheet -Address 'K67' -Value $journal.totalWaitingManhours
        }
    }

    $workbook.Save()
    Write-Output 'Header preenchido com sucesso'
}
finally {
    if ($workbook) {
        $workbook.Close($true)
        [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($workbook)
    }
    if ($excel) {
        $excel.Quit()
        [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($excel)
    }
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
}