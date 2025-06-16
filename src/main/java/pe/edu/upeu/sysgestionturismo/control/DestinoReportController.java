package pe.edu.upeu.sysgestionturismo.control;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import pe.edu.upeu.sysgestionturismo.servicio.pdf.DestinoReportService;

import java.io.ByteArrayOutputStream;

@RestController
@RequestMapping("/api/destino")
public class DestinoReportController {
    
    @Autowired
    private DestinoReportService destinoReportService;

    @GetMapping("/reporte")
    public ResponseEntity<byte[]> generarReporte() {
        try {
            ByteArrayOutputStream baos = destinoReportService.generateDestinoReport();
            byte[] pdfBytes = baos.toByteArray();

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_PDF);
            headers.setContentDispositionFormData("attachment", "reporte_destinos.pdf");

            return ResponseEntity.ok()
                    .headers(headers)
                    .body(pdfBytes);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body(null);
        }
    }
}
