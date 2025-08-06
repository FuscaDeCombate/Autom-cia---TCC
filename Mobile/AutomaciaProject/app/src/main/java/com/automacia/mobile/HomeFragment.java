package com.automacia.mobile;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.cardview.widget.CardView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;
import java.util.ArrayList;
import java.util.List;

import de.hdodenhof.circleimageview.CircleImageView;

public class HomeFragment extends Fragment {

    // Views
    private TextView tvUserName, tvCpf, tvBirthDate, tvPrescriptionStatus;
    private CircleImageView ivProfile;
    private ImageButton btnHelp, btnLogout;
    private RecyclerView rvPrescriptions;
    private CardView cardHelp, cardSendPrescription, cardMessages;
    private CardView cardAllergies, cardMedicalHistory;
    private CardView[] quickActionCards = new CardView[7];

    // Dados do usuário (normalmente viriam de uma API ou banco de dados)
    private User currentUser;
    private List<Prescription> prescriptionList;
    private PrescriptionAdapter prescriptionAdapter;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_home, container, false);

        initViews(view);
        setupUserData();
        setupRecyclerView();
        setupClickListeners();

        return view;
    }

    private void initViews(View view) {
        // Header
        btnHelp = view.findViewById(R.id.btn_help);
        btnLogout = view.findViewById(R.id.btn_logout);

        // Perfil do usuário
        ivProfile = view.findViewById(R.id.iv_profile);
        tvUserName = view.findViewById(R.id.tv_user_name);
        tvCpf = view.findViewById(R.id.tv_cpf);
        tvBirthDate = view.findViewById(R.id.tv_birth_date);
        tvPrescriptionStatus = view.findViewById(R.id.tv_prescription_status);

        // Botões de ação principais
        cardHelp = view.findViewById(R.id.card_help);
        cardSendPrescription = view.findViewById(R.id.card_send_prescription);
        cardMessages = view.findViewById(R.id.card_messages);

        // Seções principais
        cardAllergies = view.findViewById(R.id.card_allergies);
        cardMedicalHistory = view.findViewById(R.id.card_medical_history);

        // RecyclerView para receitas
        rvPrescriptions = view.findViewById(R.id.rv_prescriptions);

        // Ações rápidas
        quickActionCards[0] = view.findViewById(R.id.quick_action_1);
        quickActionCards[1] = view.findViewById(R.id.quick_action_2);
        quickActionCards[2] = view.findViewById(R.id.quick_action_3);
        quickActionCards[3] = view.findViewById(R.id.quick_action_4);
        quickActionCards[4] = view.findViewById(R.id.quick_action_5);
        quickActionCards[5] = view.findViewById(R.id.quick_action_6);
        quickActionCards[6] = view.findViewById(R.id.quick_action_7);

        // Links do rodapé
        view.findViewById(R.id.layout_website).setOnClickListener(v -> openWebsite());
        view.findViewById(R.id.layout_contact).setOnClickListener(v -> openContact());
        view.findViewById(R.id.layout_faq).setOnClickListener(v -> openFAQ());

        // Ver todas as receitas
        view.findViewById(R.id.tv_view_all_prescriptions).setOnClickListener(v -> viewAllPrescriptions());
    }

    private void setupUserData() {
        // Aqui você carregaria os dados do usuário logado
        // Por enquanto, vamos usar dados fictícios
        currentUser = new User(
                "João Silva Santos",
                "123.456.789-00",
                "15/03/1985",
                "joao.silva@email.com",
                "(11) 99999-9999"
        );

        // Atualizar UI com dados do usuário
        tvUserName.setText(currentUser.getName());
        tvCpf.setText(currentUser.getCpf());
        tvBirthDate.setText(currentUser.getBirthDate());

        // Status das receitas (normalmente viria de uma API)
        updatePrescriptionStatus();
    }

    private void setupRecyclerView() {
        // Criar lista de receitas fictícias
        prescriptionList = createSamplePrescriptions();

        prescriptionAdapter = new PrescriptionAdapter(prescriptionList, prescription -> {
            // Clique no item da receita
            openPrescriptionDetails(prescription);
        });

        rvPrescriptions.setLayoutManager(new LinearLayoutManager(getContext()));
        rvPrescriptions.setAdapter(prescriptionAdapter);
        rvPrescriptions.setNestedScrollingEnabled(false);
    }

    private void setupClickListeners() {
        // Header buttons
        btnHelp.setOnClickListener(v -> showHelp());
        btnLogout.setOnClickListener(v -> logout());

        // Botões de ação principais
        cardHelp.setOnClickListener(v -> showHelp());
        cardSendPrescription.setOnClickListener(v -> sendPrescription());
        cardMessages.setOnClickListener(v -> openMessages());

        // Seções principais
        cardAllergies.setOnClickListener(v -> openAllergies());
        cardMedicalHistory.setOnClickListener(v -> openMedicalHistory());

        // Ações rápidas
        for (int i = 0; i < quickActionCards.length; i++) {
            final int index = i;
            quickActionCards[i].setOnClickListener(v -> handleQuickAction(index));
        }
    }

    private void updatePrescriptionStatus() {
        // Aqui você faria uma chamada para a API para obter o status atual
        String status = "Você possui 2 receitas válidas.\n" +
                "1 receita foi enviada para a farmácia X.\n" +
                "Última atualização: 14/04/2025.";
        tvPrescriptionStatus.setText(status);
    }

    private List<Prescription> createSamplePrescriptions() {
        List<Prescription> prescriptions = new ArrayList<>();

        prescriptions.add(new Prescription(
                "1",
                "Receita - Antibiótico",
                "Dr. Maria Santos",
                "01/04/2025",
                "Válida",
                PrescriptionStatus.VALID
        ));

        prescriptions.add(new Prescription(
                "2",
                "Receita - Anti-inflamatório",
                "Dr. João Costa",
                "28/03/2025",
                "Enviada para Farmácia",
                PrescriptionStatus.SENT
        ));

        prescriptions.add(new Prescription(
                "3",
                "Receita - Vitaminas",
                "Dr. Ana Lima",
                "25/03/2025",
                "Processada",
                PrescriptionStatus.PROCESSED
        ));

        prescriptions.add(new Prescription(
                "4",
                "Receita - Medicamento Contínuo",
                "Dr. Carlos Ferreira",
                "20/03/2025",
                "Expirada",
                PrescriptionStatus.EXPIRED
        ));

        return prescriptions;
    }

    // Métodos de ação
    private void showHelp() {
        Toast.makeText(getContext(), "Abrindo central de ajuda...", Toast.LENGTH_SHORT).show();
        // Aqui você abriria a tela de ajuda
    }

    private void logout() {
        Toast.makeText(getContext(), "Fazendo logout...", Toast.LENGTH_SHORT).show();
        // Aqui você implementaria a lógica de logout
        // Exemplo: limpar dados de sessão e voltar para tela de login
    }

    private void sendPrescription() {
        Toast.makeText(getContext(), "Abrindo envio de receita...", Toast.LENGTH_SHORT).show();
        // Aqui você abriria a tela para enviar uma nova receita
    }

    private void openMessages() {
        Toast.makeText(getContext(), "Abrindo mensagens...", Toast.LENGTH_SHORT).show();
        // Aqui você abriria a tela de mensagens
    }

    private void openAllergies() {
        Toast.makeText(getContext(), "Abrindo alergias...", Toast.LENGTH_SHORT).show();
        // Aqui você abriria a tela de alergias
    }

    private void openMedicalHistory() {
        Toast.makeText(getContext(), "Abrindo histórico médico...", Toast.LENGTH_SHORT).show();
        // Aqui você abriria a tela de histórico médico
    }

    private void openPrescriptionDetails(Prescription prescription) {
        Toast.makeText(getContext(), "Abrindo detalhes: " + prescription.getTitle(), Toast.LENGTH_SHORT).show();
        // Aqui você abriria a tela de detalhes da receita
    }

    private void viewAllPrescriptions() {
        Toast.makeText(getContext(), "Abrindo todas as receitas...", Toast.LENGTH_SHORT).show();
        // Aqui você abriria a tela com todas as receitas
    }

    private void handleQuickAction(int actionIndex) {
        String[] actions = {
                "Médicos", "Farmácias", "Agendamentos", "Relatórios",
                "Consultas", "Configurações", "Favoritos"
        };

        if (actionIndex < actions.length) {
            Toast.makeText(getContext(), "Abrindo: " + actions[actionIndex], Toast.LENGTH_SHORT).show();
            // Aqui você implementaria a ação específica
        }
    }

    private void openWebsite() {
        try {
            Intent intent = new Intent(Intent.ACTION_VIEW);
            intent.setData(Uri.parse("https://www.medconnect.com"));
            startActivity(intent);
        } catch (Exception e) {
            Toast.makeText(getContext(), "Não foi possível abrir o website", Toast.LENGTH_SHORT).show();
        }
    }

    private void openContact() {
        try {
            Intent intent = new Intent(Intent.ACTION_DIAL);
            intent.setData(Uri.parse("tel:+5511999999999"));
            startActivity(intent);
        } catch (Exception e) {
            Toast.makeText(getContext(), "Não foi possível abrir o discador", Toast.LENGTH_SHORT).show();
        }
    }

    private void openFAQ() {
        Toast.makeText(getContext(), "Abrindo FAQ...", Toast.LENGTH_SHORT).show();
        // Aqui você abriria a tela de FAQ
    }

    // Classes modelo
    public static class User {
        private String name;
        private String cpf;
        private String birthDate;
        private String email;
        private String phone;

        public User(String name, String cpf, String birthDate, String email, String phone) {
            this.name = name;
            this.cpf = cpf;
            this.birthDate = birthDate;
            this.email = email;
            this.phone = phone;
        }

        // Getters
        public String getName() { return name; }
        public String getCpf() { return cpf; }
        public String getBirthDate() { return birthDate; }
        public String getEmail() { return email; }
        public String getPhone() { return phone; }
    }

    public static class Prescription {
        private String id;
        private String title;
        private String doctor;
        private String date;
        private String statusText;
        private PrescriptionStatus status;

        public Prescription(String id, String title, String doctor, String date, String statusText, PrescriptionStatus status) {
            this.id = id;
            this.title = title;
            this.doctor = doctor;
            this.date = date;
            this.statusText = statusText;
            this.status = status;
        }

        // Getters
        public String getId() { return id; }
        public String getTitle() { return title; }
        public String getDoctor() { return doctor; }
        public String getDate() { return date; }
        public String getStatusText() { return statusText; }
        public PrescriptionStatus getStatus() { return status; }
    }

    public enum PrescriptionStatus {
        VALID, SENT, PROCESSED, EXPIRED, CANCELLED
    }
}