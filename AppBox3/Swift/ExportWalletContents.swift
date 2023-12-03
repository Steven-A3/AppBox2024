//
//  ExportWalletContents.swift
//  AppBox3
//
//  Created by BYEONG KWON KWAK on 12/1/23.
//  Copyright © 2023 ALLABOUTAPPS. All rights reserved.
//

import SwiftXLSX

func createExcelRepresentation() -> XWorkBook {
    let book = XWorkBook()

    let categories = WalletCategory.findAllSortedBy("order", ascending: true)
    for category in categories {
        if category.uniqueID == A3WalletUUIDAllCategory || category.uniqueID == A3WalletUUIDFavoriteCategory {
            continue
        }

        var sheet = book.NewSheet(category.name)
        let fields = WalletField.findByAttribute("categoryID", withValue: category.uniqueID)

        // Create header row
        var headerRow = [XCell]()
        headerRow.append(XCell(value: .text("Title")))
        for field in fields {
            headerRow.append(XCell(value: .text(field.name)))
        }
        headerRow.append(XCell(value: .text("Memo")))
        sheet.AddRow(headerRow)

        // Create data rows
        let allRows = WalletItem.findAllSortedBy("name", ascending: true, withPredicate: NSPredicate(format: "categoryID == %@", category.uniqueID))
        for row in allRows {
            var dataRow = [XCell(value: .text(row.name))]
            for field in fields {
                let fieldPredicate = NSPredicate(format: "walletItemID == %@ AND fieldID == %@", row.uniqueID, field.uniqueID)
                let fieldItems = WalletFieldItem.findAllWithPredicate(fieldPredicate)
                let fieldValue = fieldItems.first?.value ?? ""
                dataRow.append(XCell(value: .text(fieldValue)))
            }
            dataRow.append(XCell(value: .text(row.note)))
            sheet.AddRow(dataRow)
        }
    }

    return book
}
