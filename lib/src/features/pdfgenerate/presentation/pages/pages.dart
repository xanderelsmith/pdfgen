// ignore_for_file: public_member_api_docs, sort_constructors_first
///Package imports
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdfgen/src/features/pdfgenerate/data/model/report.dart';
import 'package:pdfgen/src/features/pdfgenerate/data/save_file_web.dart';

///Pdf import
import 'package:syncfusion_flutter_pdf/pdf.dart';

class InvoicePdf extends StatefulWidget {
  const InvoicePdf({super.key});

  @override
  State<InvoicePdf> createState() => _InvoicePdfState();
}

class _InvoicePdfState extends State<InvoicePdf> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: model.sampleOutputCardColor,
        body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
                'The PDF package is a non-UI and reusable flutter library to create PDF reports programmatically with formatted text, images, tables, links, list, header and footer, and more.\r\n\r\nThis sample showcase how to create a simple invoice report using PDF grid with built-in styles.',
                style: TextStyle(
                  fontSize: 16,
                  // color: model.textColor
                )),
            const SizedBox(height: 20, width: 30),
            Align(
                child: TextButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(
                    Theme.of(context).primaryColor),
                padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 15)),
              ),
              onPressed: () async {
                Future<List<int>> _readImageData(String name) async {
                  final ByteData data =
                      await rootBundle.load('images/pdf/$name');
                  return data.buffer
                      .asUint8List(data.offsetInBytes, data.lengthInBytes);
                }

                List<int> closedImage =
                    await _readImageData('asset/image/closed.png');
                List<int> openImage =
                    await _readImageData('asset/image/open.png');
                _generatePDF(
                  closedImage,
                  openImage,
                );
              },
              child: const Text('Generate PDF',
                  style: TextStyle(color: Colors.white)),
            ))
          ],
        ),
      ),
    ));
  }

  Future<void> _generatePDF(
    closedImage,
    openImage,
  ) async {
    final reportData = Report(
        location: 'location',
        companyname: 'companyname',
        age: 'age',
        gender: 'gender');
    //Create a PDF document.
    final PdfDocument document = PdfDocument();
    document.pageSettings.margins.all = 20;
    //Add page to the PDF
    final PdfPage page = document.pages.add();
    final PdfPage page3 = document.pages.add();
    //Get page client size
    final Size pageSize = page.getClientSize();

    //Generate PDF grid.
    final PdfGrid grid = _getGrid(pageSize, page);
    //Draw the header section by creating text element
    final PdfLayoutResult result = _drawHeader(page, pageSize, grid);
    //Draw grid

    _drawGrid(page, grid, result); //Draw rectangle
    drawhereditaryTable(
      page3,
      pageSize,
      closedImage,
      openImage,
    );
    //Add invoice footer
    // _drawFooter(page, pageSize);
    //Save and dispose the document.
    final List<int> bytes = await document.save();
    document.dispose();
    //Launch file.
    await FileSaveHelper.saveAndLaunchFile(bytes, 'EmmanuelGEnpdf.pdf');
  }

  void drawhereditaryTable(
    PdfPage page,
    Size pageSize,
    closedImage,
    openImage,
  ) {
    var baseBounds = Rect.fromLTWH(0, 150, pageSize.width, 20);

    page.graphics.drawRectangle(
        brush: PdfSolidBrush(PdfColor(91, 126, 215)), bounds: baseBounds);
    page.graphics.drawString('Hereditary and family History',
        PdfStandardFont(PdfFontFamily.helvetica, 10),
        bounds: Rect.fromLTWH(130, 155, pageSize.width - 400, 100),
        brush: PdfBrushes.white,
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.top));
    page.graphics.drawRectangle(
        brush: PdfBrushes.lightSteelBlue,
        pen: PdfPen(PdfColor(142, 170, 219)),
        bounds: Rect.fromLTWH(0, 170, pageSize.width, 20));
    page.graphics.drawString(
        'Mom', PdfStandardFont(PdfFontFamily.helvetica, 10),
        bounds: Rect.fromLTWH(pageSize.width / 2.34, 175, 50, 50));
    page.graphics.drawString(
        'Dad', PdfStandardFont(PdfFontFamily.helvetica, 10),
        bounds: Rect.fromLTWH(pageSize.width / 1.74, 175, 50, 50));
    page.graphics.drawString(
        'Siblings', PdfStandardFont(PdfFontFamily.helvetica, 10),
        bounds: Rect.fromLTWH(pageSize.width / 1.35, 175, 50, 50));
    page.graphics.drawString(
        'Not Known', PdfStandardFont(PdfFontFamily.helvetica, 10),
        bounds: Rect.fromLTWH(pageSize.width / 1.15, 175, 50, 50));

    List<HereditaryRelationsData> hereditarydataList = [
      HereditaryRelationsData(
        name: 'Alcoholismo',
        momHas: true,
        dadHas: true,
        siblingsHave: true,
        othersHave: false,
      ),
      HereditaryRelationsData(
        name: 'Artritis',
      ),
      HereditaryRelationsData(
        name: 'Cancer',
      ),
      HereditaryRelationsData(
        name: 'Depresion',
      ),
      HereditaryRelationsData(
        name: 'Diabetes miletus',
      ),
      HereditaryRelationsData(
        name: 'Obesity',
      ),
      HereditaryRelationsData(name: 'Smoking'),
    ];

    for (var i = 0; i < hereditarydataList.length; i++) {
      heridiraryTile(page, pageSize, i, closedImage, openImage,
          hereditaryRelationsData: hereditarydataList[i]);
    }
  }

  void heridiraryTile(PdfPage page, pageSize, i, closedImage, openImage,
      {required HereditaryRelationsData hereditaryRelationsData}) async {
    var top = (190 + 20 * (i)).toDouble();
    page.graphics.drawRectangle(
        pen: PdfPen(PdfColor(142, 170, 219)),
        bounds: Rect.fromLTWH(0, top, pageSize.width, 20));
    page.graphics.drawRectangle(
        brush: PdfBrushes.lightSteelBlue,
        pen: PdfPen(PdfColor(142, 170, 219)),
        bounds: Rect.fromLTWH(0, top, pageSize.width / 3, 20));
    page.graphics.drawString(hereditaryRelationsData.name,
        PdfStandardFont(PdfFontFamily.helvetica, 10),
        bounds: Rect.fromLTWH(50, top + 5, 200, 50));
    double width = 10;
    double height = 10;

    page.graphics.drawImage(
        PdfBitmap(hereditaryRelationsData.momHas ? closedImage : openImage),
        Rect.fromLTWH(pageSize.width / 2.3, top + 5, width, height));
    page.graphics.drawImage(
        PdfBitmap(hereditaryRelationsData.dadHas ? closedImage : openImage),
        Rect.fromLTWH(pageSize.width / 1.7, top + 5, width, height));
    page.graphics.drawImage(
        PdfBitmap(
            hereditaryRelationsData.siblingsHave ? closedImage : openImage),
        Rect.fromLTWH(pageSize.width / 1.3, top + 5, width, height));
    page.graphics.drawImage(
        PdfBitmap(hereditaryRelationsData.othersHave ? closedImage : openImage),
        Rect.fromLTWH(pageSize.width / 1.1, top + 5, width, height));
  }

  //Draws the invoice header
  PdfLayoutResult _drawHeader(PdfPage page, Size pageSize, PdfGrid grid) {
    page.graphics.drawString(
        'Page: 1 of 5:', PdfStandardFont(PdfFontFamily.helvetica, 10),
        bounds: Rect.fromLTWH(400, 0, pageSize.width - 400, 100),
        brush: PdfBrushes.gray,
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.top));
    page.graphics.drawString(
        'Historica Clinica:', PdfStandardFont(PdfFontFamily.helvetica, 11),
        bounds: Rect.fromLTWH(130, 30, pageSize.width - 400, 100),
        brush: PdfBrushes.gray,
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.top));
    final PdfFont contentFont = PdfStandardFont(PdfFontFamily.helvetica, 9);
    //Draw string
    page.graphics.drawString(
        'First Name, Last Name, Second, Last Name', contentFont,
        brush: PdfBrushes.blue,
        bounds: Rect.fromLTWH(290, 30, pageSize.width - 100, 50));
    // format: PdfStringFormat(
    //     alignment: PdfTextAlignment.r,
    //     lineAlignment: PdfVerticalAlignment.top));
    page.graphics.drawString(
        'Historica Clinica:', PdfStandardFont(PdfFontFamily.helvetica, 11),
        bounds: Rect.fromLTWH(130, 45, pageSize.width - 400, 100),
        brush: PdfBrushes.gray,
        format: PdfStringFormat(
            alignment: PdfTextAlignment.right,
            lineAlignment: PdfVerticalAlignment.top));
    final DateFormat format = DateFormat.yMMMMd('en_US');
    const String invoiceNumber =
        'Sucursal: Chilo\r\n\rSexo: Hombre\r\n\r\Puesto: Hombre\r\n\r\Lugar de Nacimiento: Ciudad Mexico';
    final Size contentSize =
        contentFont.measureString(invoiceNumber, format: PdfStringFormat());

    //Draw string
    page.graphics.drawString(DateTime.now().toString(), contentFont,
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH(290, 45, pageSize.width - 100, 50),
        format: PdfStringFormat(
            alignment: PdfTextAlignment.left,
            lineAlignment: PdfVerticalAlignment.top));
    //Create data foramt and convert it to text.
    const String address =
        'Empresa: Abraham Swearegin, \r\n\r\nEdad: 18, \r\n\r\Telefono: 555555555, \r\n\r\Lugar de residenci668 Col. Polanco Seccion Va: AV Ejecito Nacional ';
    PdfTextElement(text: invoiceNumber, font: contentFont).draw(
        page: page,
        bounds: Rect.fromLTWH(pageSize.width - (contentSize.width + 30), 80,
            contentSize.width + 30, pageSize.height - 120));
    return PdfTextElement(text: address, font: contentFont).draw(
        page: page,
        bounds: Rect.fromLTWH(30, 80, pageSize.width - (contentSize.width + 30),
            pageSize.height - 120))!;
  }

  //Draws the grid
  PdfLayoutResult _drawGrid(
      PdfPage page, PdfGrid grid, PdfLayoutResult result) {
    Rect? totalPriceCellBounds;
    Rect? quantityCellBounds;
    //Invoke the beginCellLayout event.
    grid.beginCellLayout = (Object sender, PdfGridBeginCellLayoutArgs args) {
      final PdfGrid grid = sender as PdfGrid;
      if (args.cellIndex == grid.columns.count - 1) {
        totalPriceCellBounds = args.bounds;
      } else if (args.cellIndex == grid.columns.count - 2) {
        quantityCellBounds = args.bounds;
      }
    };
    log(result!.bounds.toString());
    //Draw the PDF grid and get the result.
    result = grid.draw(
        page: page, bounds: Rect.fromLTWH(0, result.bounds.bottom + 40, 0, 0))!;
    log(result!.bounds.toString());
    return result;
  }

  //Draw the invoice footer data.
  void _drawFooter(PdfPage page, Size pageSize) {
    final PdfPen linePen =
        PdfPen(PdfColor(142, 170, 219), dashStyle: PdfDashStyle.custom);
    linePen.dashPattern = <double>[3, 3];
    //Draw line
    page.graphics.drawLine(linePen, Offset(0, pageSize.height - 100),
        Offset(pageSize.width, pageSize.height - 100));
    const String footerContent =
        '800 Interchange Blvd.\r\n\r\nSuite 2501, Austin, TX 78721\r\n\r\nAny Questions? support@adventure-works.com';
    //Added 30 as a margin for the layout
    page.graphics.drawString(
        footerContent, PdfStandardFont(PdfFontFamily.helvetica, 9),
        format: PdfStringFormat(alignment: PdfTextAlignment.right),
        bounds: Rect.fromLTWH(pageSize.width - 30, pageSize.height - 70, 0, 0));
  }

//Get the total amount.
  double _getTotalAmount(PdfGrid grid) {
    double total = 0;
    for (int i = 0; i < grid.rows.count; i++) {
      final String value =
          grid.rows[i].cells[grid.columns.count - 1].value as String;
      total += double.parse(value);
    }
    return 10;
  }
}

//Create PDF grid and return
PdfGrid _getGrid(Size pageSize, PdfPage page) {
  //Create a PDF grid
  final PdfGrid grid = PdfGrid();
  //Secify the columns count to the grid.

  grid.columns.add(count: 5);
  //Create the header row of the grid.
  final PdfGridRow firstheaderRow = grid.headers.add(1)[0];

  var headercell = firstheaderRow.cells[0];
  headercell.value = 'PADECIMIENTO ACTUAL';

  headercell.style = PdfGridCellStyle(
    cellPadding: PdfPaddings(),
  );
  headercell.stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle);
  final PdfGridRow headerRow = grid.headers.add(1)[1];
  //Set style
  firstheaderRow.style.backgroundBrush = PdfSolidBrush(PdfColor(68, 014, 196));
  firstheaderRow.style.textBrush = PdfBrushes.white;

  _formDetails('?ACTALMENTE SIENTES DE SALUD?', 'Si', grid);
  _formDetails(
      'DIARREA CON SANGRE',
      additionalComment: 'Yes i have diarhoea',
      'Si',
      grid);
  _formDetails('COMENTARIOS ADICIONALES', 'Si', grid,
      additionalComment:
          'Weakness, tiredness, have you turned pale, are you short of breath when exercising');
  _formDetails('LJ-0192', 'Si', grid);
  _formDetails('FK-5136', 'Si', grid);
  _formDetails('HL-U509', 'Si', grid);
  _formDetails('LJ-0192', 'Si', grid);
  _formDetails('FK-5136', 'Si', grid);
  _formDetails('HL-U509', 'Si', grid);
  _formDetails('LJ-0192', 'Si', grid);
  _formDetails('FK-5136', 'Si', grid);
  _formDetails('HL-U509', 'Si', grid);
  _formDetails('LJ-0192', 'Si', grid);
  _formDetails('FK-5136', 'Si', grid);
  _formDetails('HL-U509', 'Si', grid);
  _formDetails('LJ-0192', 'Si', grid);
  _formDetails('FK-5136', 'Si', grid);
  _formDetails('HL-U509', 'Si', grid);
  _formDetails('LJ-0192', 'Si', grid);
  _formDetails('FK-5136', 'Si', grid);
  _formDetails('HL-U509', 'Si', grid);

  grid.applyBuiltInStyle(
    PdfGridBuiltInStyle.listTable4Accent5,
  );
  // grid.columns[1].width = 200;
  grid.columns[0].width = pageSize.width / 1.6;
  grid.columns[0].format = PdfStringFormat(
    alignment: PdfTextAlignment.left,
    lineAlignment: PdfVerticalAlignment.top,
  );

  for (int i = 0; i < headerRow.cells.count; i++) {
    headerRow.cells[i].stringFormat = PdfStringFormat(
        alignment: PdfTextAlignment.center,
        lineAlignment: PdfVerticalAlignment.middle);
  }
  var bounds = Rect.fromLTWH(0, 150, pageSize.width, 20);
  for (int i = 0; i < grid.rows.count; i++) {
    final PdfGridRow row = grid.rows[i];
    for (int j = 0; j < row.cells.count; j++) {
      final PdfGridCell cell = row.cells[j];
      if (j == 0) {
        cell
          ..stringFormat = PdfStringFormat(
            alignment: PdfTextAlignment.left,
          )
          ..style;
      }

      cell.style.cellPadding =
          PdfPaddings(bottom: 10, left: 5, right: 5, top: 10);
    }
  }
  return grid;
}

//Create and row for the grid.
void _formDetails(String question, String total, PdfGrid grid,
    {String? additionalComment, bool? isSubCategory}) {
  final PdfGridRow row = grid.rows.add();
  row.cells[0].value =
      '$question${additionalComment != null ? '\n\nComentarios Adicionales:\t$additionalComment' : ''}';
  if (isSubCategory = true) {}

  row.cells[4].value = total.toString();
}

class HereditaryRelationsData {
  final String name;
  final bool momHas;
  final bool dadHas;
  final bool siblingsHave;
  final bool othersHave;
  HereditaryRelationsData({
    required this.name,
    this.momHas = false,
    this.dadHas = false,
    this.siblingsHave = false,
    this.othersHave = false,
  });
}
