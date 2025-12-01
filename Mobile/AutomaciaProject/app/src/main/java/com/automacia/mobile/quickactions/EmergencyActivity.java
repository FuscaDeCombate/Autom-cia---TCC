package com.automacia.mobile.quickactions;

import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.automacia.mobile.R;
import com.automacia.mobile.adapters.EmergencyMedicationAdapter;
import com.automacia.mobile.models.PrescriptionDTO;
import com.google.android.material.button.MaterialButton;
import java.util.ArrayList;
import java.util.List;

public class EmergencyActivity extends AppCompatActivity {

    private RecyclerView recyclerMedications;
    private MaterialButton btnCallSamu;
    private MaterialButton btnCopyMedications;
    private MaterialButton btnCallCeatox;
    private LinearLayout medicationsSection;

    private EmergencyMedicationAdapter adapter;
    private List<PrescriptionDTO> prescriptions;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_emergency);

        getWindow().setStatusBarColor(ContextCompat.getColor(this, R.color.primary));

        initViews();
        loadPrescriptions();
        setupRecyclerView();
        setupButtons();
    }

    private void initViews() {
        recyclerMedications = findViewById(R.id.recyclerMedications);
        btnCallSamu = findViewById(R.id.btnCallSamu);
        btnCopyMedications = findViewById(R.id.btnCopyMedications);
        btnCallCeatox = findViewById(R.id.btnCallCeatox);
    }

    private void loadPrescriptions() {
        // Receber lista de receitas via Intent
        prescriptions = (List<PrescriptionDTO>) getIntent().getSerializableExtra("prescriptions_list");

        if (prescriptions == null) {
            prescriptions = new ArrayList<>();
        }
    }

    private void setupRecyclerView() {
        adapter = new EmergencyMedicationAdapter(prescriptions);
        recyclerMedications.setLayoutManager(new LinearLayoutManager(this));
        recyclerMedications.setAdapter(adapter);

        // Se não houver medicamentos, esconder seção
        if (prescriptions.isEmpty()) {
            recyclerMedications.setVisibility(View.GONE);
            btnCopyMedications.setVisibility(View.GONE);

            // Esconder também o título e ícone da seção de medicamentos (se existir)
            View medicationsHeader = findViewById(R.id.medicationsHeader);
            if (medicationsHeader != null) {
                medicationsHeader.setVisibility(View.GONE);
            }
        }
    }

    private void setupButtons() {
        // Botão SAMU - Ação Principal
        btnCallSamu.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                callSamu();
            }
        });

        // Botão Copiar Medicamentos
        btnCopyMedications.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                copyMedicationsToClipboard();
            }
        });

        // Botão CEATOX
        btnCallCeatox.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                callCeatox();
            }
        });
    }

    private void callSamu() {
        Intent intent = new Intent(Intent.ACTION_DIAL);
        intent.setData(Uri.parse("tel:192"));

        if (intent.resolveActivity(getPackageManager()) != null) {
            startActivity(intent);
        } else {
            Toast.makeText(this, "Não foi possível abrir o discador", Toast.LENGTH_SHORT).show();
        }
    }

    private void callCeatox() {
        // CEATOX - Centro de Assistência Toxicológica
        Intent intent = new Intent(Intent.ACTION_DIAL);
        intent.setData(Uri.parse("tel:08007226001"));

        if (intent.resolveActivity(getPackageManager()) != null) {
            startActivity(intent);
        } else {
            Toast.makeText(this, "Não foi possível abrir o discador", Toast.LENGTH_SHORT).show();
        }
    }

    private void copyMedicationsToClipboard() {
        if (prescriptions.isEmpty()) {
            Toast.makeText(this, "Nenhum medicamento para copiar", Toast.LENGTH_SHORT).show();
            return;
        }

        StringBuilder medicationList = new StringBuilder();
        medicationList.append("📋 MEDICAMENTOS EM USO\n");
        medicationList.append("━━━━━━━━━━━━━━━━━━━━━━\n\n");

        int activePrescriptions = 0;
        int inactivePrescriptions = 0;

        // Contar ativos e inativos
        for (PrescriptionDTO prescription : prescriptions) {
            if (prescription.isValido()) {
                activePrescriptions++;
            } else {
                inactivePrescriptions++;
            }
        }

        // Adicionar resumo
        medicationList.append("Total: ").append(prescriptions.size()).append(" medicamento(s)\n");
        medicationList.append("Ativos: ").append(activePrescriptions).append(" | ");
        medicationList.append("Inativos: ").append(inactivePrescriptions).append("\n\n");
        medicationList.append("━━━━━━━━━━━━━━━━━━━━━━\n\n");

        // Listar medicamentos
        for (int i = 0; i < prescriptions.size(); i++) {
            PrescriptionDTO prescription = prescriptions.get(i);

            medicationList.append((i + 1)).append(". ")
                    .append(prescription.getMedicamento())
                    .append(prescription.isValido() ? " ✓" : " ✗")
                    .append("\n");

            if (prescription.getDetalhes() != null && !prescription.getDetalhes().trim().isEmpty()) {
                medicationList.append("   💊 Detalhes: ")
                        .append(prescription.getDetalhes())
                        .append("\n");
            }

            medicationList.append("   📌 Status: ")
                    .append(prescription.isValido() ? "Ativa" : "Inativa")
                    .append("\n");

            if (prescription.getFuncionarioNome() != null && !prescription.getFuncionarioNome().trim().isEmpty()) {
                medicationList.append("   👨‍⚕️ Prescrito por: ")
                        .append(prescription.getFuncionarioNome())
                        .append("\n");
            }

            if (i < prescriptions.size() - 1) {
                medicationList.append("\n");
            }
        }

        medicationList.append("\n━━━━━━━━━━━━━━━━━━━━━━\n");
        medicationList.append("Gerado em: ").append(new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm", java.util.Locale.getDefault()).format(new java.util.Date()));

        // Copiar para clipboard
        ClipboardManager clipboard = (ClipboardManager) getSystemService(Context.CLIPBOARD_SERVICE);
        ClipData clip = ClipData.newPlainText("Medicamentos", medicationList.toString());

        if (clipboard != null) {
            clipboard.setPrimaryClip(clip);
            Toast.makeText(this, "✓ Lista copiada para área de transferência", Toast.LENGTH_SHORT).show();
        } else {
            Toast.makeText(this, "Erro ao copiar lista", Toast.LENGTH_SHORT).show();
        }
    }
}