/**
 * jsPDF AutoTable plugin
 * Copyright (c) 2014 Simon Bengtsson, https://github.com/someatoms/jsPDF-AutoTable
 *
 * Licensed under the MIT License.
 * http://opensource.org/licenses/mit-license
 */
(function (API) {
    'use strict';

    // On every new jsPDF object, clear variables
    API.events.push(['initialized', function () {
        doc = undefined;
        cellPos = undefined;
        pageCount = 1;
        settings = undefined;
    }], false);

    var MIN_COLUMN_WIDTH = 25;

    var doc, cellPos, pageCount = 1, settings;

    // See README.md or examples for documentation of the options
    // return a new instance every time to avoid references issues
    var defaultOptions = function () {
        return {
            padding: 5,
            fontSize: 10,
            lineHeight: 20,
            renderHeader: function (doc, pageNumber, settings) {
            },
            renderFooter: function (doc, lastCellPos, pageNumber, settings) {
            },
            renderHeaderCell: function (x, y, width, height, key, value, settings) {
                doc.setFillColor(52, 73, 94); // Asphalt
                doc.setTextColor(255, 255, 255);
                doc.setFontStyle('bold');
                doc.rect(x, y, width, height, 'F');
                y += settings.lineHeight / 2 + doc.internal.getLineHeight() / 2;
                doc.text('' + value, x + settings.padding, y);
            },
            renderCell: function (x, y, width, height, key, value, row, settings) {
                doc.setFillColor(row % 2 === 0 ? 245 : 255);
                doc.setTextColor(50);
                doc.rect(x, y, width, height, 'F');
                y += settings.lineHeight / 2 + doc.internal.getLineHeight() / 2 - 2.5;
                doc.text('' + value, x + settings.padding, y);
            },
            margins: {horizontal: 40, top: 50, bottom: 40},
            startY: false,
            avoidPageSplit: false,
            extendWidth: true
        }
    };

    /**
     * Create a table from a set of rows and columns.
     *
     * @param {Object[]|String[]} columns Either as an array of objects or array of strings
     * @param {Object[][]|String[][]} data Either as an array of objects or array of strings
     * @param {Object} [options={}] Options that will override the default ones (above)
     */
    API.autoTable = function (columns, data, options) {
        options = options || {};
        columns = columns || [];
        doc = this;

        var userFontSize = doc.internal.getFontSize();

        initData({columns: columns, data: data});
        initOptions(options);

        cellPos = {
            x: settings.margins.horizontal,
            y: settings.startY === false ? settings.margins.top : settings.startY
        };

        var tableHeight = settings.margins.bottom + settings.margins.top + settings.lineHeight * (data.length + 1) + 5 + settings.startY;
        if (settings.startY !== false && settings.avoidPageSplit && tableHeight > doc.internal.pageSize.height) {
            doc.addPage();
            cellPos.y = settings.margins.top;
        }

        settings.renderHeader(doc, pageCount, settings);
        var columnWidths = calculateColumnWidths(data, columns);
        printHeader(columns, columnWidths);
        printRows(columns, data, columnWidths);
        settings.renderFooter(doc, cellPos, pageCount, settings);

        doc.setFontSize(userFontSize);

        return this;
    };

    /**
     * Returns the Y position of the last drawn cell
     * @returns int
     */
    API.autoTableEndPosY = function () {
        // If cellPos is not set, autoTable() as probably not been called
        return cellPos ? cellPos.y : false;
    };

    /**
     * @deprecated Use autoTableEndPosY()
     */
    API.autoTableEndPos = function () {
        return cellPos;
    };

    /**
     * Parses an html table. To draw a table, use it like this:
     * `doc.autoTable(false, doc.autoTableHtmlToJson(table))`
     *
     * @param table Html table element
     * @returns [] Array of objects with object keys as headers
     */
    API.autoTableHtmlToJson = function (table) {
        var data = [], headers = {}, header = table.rows[0];
        for (var i = 0; i < header.cells.length; i++) {
            headers[i] = header.cells[i] ? header.cells[i].textContent : '';
        }

        for (i = 1; i < table.rows.length; i++) {
            var tableRow = table.rows[i];
            var rowData = {};
            for (var j = 0; j < header.cells.length; j++) {
                rowData[headers[j]] = tableRow.cells[j] ? tableRow.cells[j].textContent : '';
            }
            data.push(rowData);
        }
        return data;
    };

    /**
     * Transform all to the object initialization form
     * @param params
     */
    function initData(params) {
        // Object only initial
        if (!params.columns || params.columns.length === 0) {
            var keys = Object.keys(params.data[0]);
            Array.prototype.push.apply(params.columns, keys);
            params.columns.forEach(function (title, i) {
                params.columns[i] = {title: title, key: keys[i]};
            });
        }
        // Array initialization form
        else if (typeof params.columns[0] === 'string') {
            params.data.forEach(function (row, i) {
                var obj = {};
                for (var j = 0; j < row.length; j++) {
                    obj[j] = params.data[i][j];
                }
                params.data[i] = obj;
            });
            params.columns.forEach(function (title, i) {
                params.columns[i] = {title: title, key: i};
            });
        }

    }

    function initOptions(raw) {
        settings = defaultOptions();
        Object.keys(raw).forEach(function (key) {
            settings[key] = raw[key];
        });
        doc.setFontSize(settings.fontSize);
    }

    function calculateColumnWidths(rows, columns) {
        var widths = {};

        // Optimal widths
        var totalWidth = 0;
        columns.forEach(function (header) {
            var widest = getStringWidth(header.title || '');
            rows.forEach(function (row) {
                if (!header.hasOwnProperty('key'))
                    throw new Error("The key attribute is required in every header");
                var w = getStringWidth(prop(row, header.key));
                if (w > widest) {
                    widest = w;
                }
            });
            widths[header.key] = widest;
            totalWidth += widest;
        });

        var paddingAndMargin = settings.padding * 2 * columns.length + settings.margins.horizontal * 2;
        var spaceDiff = doc.internal.pageSize.width - totalWidth - paddingAndMargin;

        var keys = Object.keys(widths);
        if (spaceDiff < 0) {
            // Shrink columns
            var shrinkableColumns = [];
            var shrinkableColumnWidths = 0;
            keys.forEach(function (key) {
                if (widths[key] > MIN_COLUMN_WIDTH) {
                    shrinkableColumns.push(key);
                    shrinkableColumnWidths += widths[key];
                }
            });
            shrinkableColumns.forEach(function (key) {
                widths[key] += spaceDiff * (widths[key] / shrinkableColumnWidths);
            });
        } else if (spaceDiff > 0 && settings.extendWidth) {
            // Fill page horizontally
            keys.forEach(function (key) {
                widths[key] += spaceDiff / keys.length;
            });
        }

        return widths;
    }

    function printHeader(headers, columnWidths) {
        if (!headers) return; //
        headers.forEach(function (header) {
            var width = columnWidths[header.key] + settings.padding * 2;
            var title = ellipsize(columnWidths[header.key] || '', header.title || '');
            settings.renderHeaderCell(cellPos.x, cellPos.y, width, settings.lineHeight + 5, header.key, title, settings);
            cellPos.x += width;
        });
        doc.setTextColor(70, 70, 70);
        doc.setFontStyle('normal');

        cellPos.y += settings.lineHeight + 5;
        cellPos.x = settings.margins.horizontal;
    }

    function printRows(headers, rows, columnWidths) {
        for (var i = 0; i < rows.length; i++) {
            var row = rows[i];

            headers.forEach(function (header) {
                var title = ellipsize(columnWidths[header.key] || '', prop(row, header.key));
                var width = columnWidths[header.key] + settings.padding * 2;
                settings.renderCell(cellPos.x, cellPos.y, width, settings.lineHeight, header.key, title, i, settings);
                cellPos.x = cellPos.x + columnWidths[header.key] + settings.padding * 2;
            });

            var newPage = (cellPos.y + settings.margins.bottom + settings.lineHeight * 2) >= doc.internal.pageSize.height;
            if (newPage) {
                settings.renderFooter(doc, cellPos, pageCount, settings);
                doc.addPage();
                cellPos = {x: settings.margins.horizontal, y: settings.margins.top};
                pageCount++;
                settings.renderHeader(doc, pageCount, settings);
                printHeader(headers, columnWidths);
            } else {
                cellPos.y += settings.lineHeight;
                cellPos.x = settings.margins.horizontal;
            }
        }
    }

    /**
     * Ellipsize the text to fit in the width
     * @param width
     * @param text
     */
    function ellipsize(width, text) {
        var isBold = doc.internal.getFont().fontStyle === 'bold';
        if (width + (isBold ? 5 : 0) >= getStringWidth(text)) {
            return text;
        }
        while (width < getStringWidth(text + "...")) {
            if (text.length < 2) {
                break;
            }
            text = text.substring(0, text.length - 1);
        }
        text += "...";
        return text;
    }

    function prop(row, key) {
        return row.hasOwnProperty(key) ? '' + row[key] : '';
    }

    function getStringWidth(txt) {
        return doc.getStringUnitWidth(txt) * doc.internal.getFontSize();
    }

})(jsPDF.API);