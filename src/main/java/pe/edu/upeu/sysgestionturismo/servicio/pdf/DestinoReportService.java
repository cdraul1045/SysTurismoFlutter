package pe.edu.upeu.sysgestionturismo.servicio.pdf;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import pe.edu.upeu.sysgestionturismo.modelo.Destino;
import pe.edu.upeu.sysgestionturismo.servicio.IDestinoService;

import java.io.ByteArrayOutputStream;
import java.util.List;

@Service
public class DestinoReportService {
    
    @Autowired
    private IDestinoService destinoService;

    public ByteArrayOutputStream generateDestinoReport() throws DocumentException {
        Document document = new Document();
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        
        PdfWriter.getInstance(document, baos);
        document.open();

        // Add title
        Font titleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 18, BaseColor.BLACK);
        Paragraph title = new Paragraph("Reporte de Destinos Turísticos", titleFont);
        title.setAlignment(Element.ALIGN_CENTER);
        document.add(title);
        document.add(new Paragraph("\n"));

        // Add date
        Font dateFont = FontFactory.getFont(FontFactory.HELVETICA, 12, BaseColor.BLACK);
        Paragraph date = new Paragraph("Fecha: " + new java.util.Date(), dateFont);
        date.setAlignment(Element.ALIGN_RIGHT);
        document.add(date);
        document.add(new Paragraph("\n"));

        // Create table
        PdfPTable table = new PdfPTable(5);
        table.setWidthPercentage(100);
        
        // Add headers
        String[] headers = {"ID", "Nombre", "Descripción", "Ubicación", "Imagen"};
        for (String header : headers) {
            PdfPCell cell = new PdfPCell(new Phrase(header, FontFactory.getFont(FontFactory.HELVETICA_BOLD, 12, BaseColor.BLACK)));
            cell.setBackgroundColor(BaseColor.LIGHT_GRAY);
            table.addCell(cell);
        }

        // Add data
        List<Destino> destinos = destinoService.findAll();
        for (Destino destino : destinos) {
            table.addCell(destino.getIdDestino().toString());
            table.addCell(destino.getNombre());
            table.addCell(destino.getDescripcion());
            table.addCell(destino.getUbicacion());
            table.addCell(destino.getImagenPath());
        }

        document.add(table);
        document.close();

        return baos;
    }
}
