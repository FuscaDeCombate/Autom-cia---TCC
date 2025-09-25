package com.automacia.mobile.fragments;

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
import android.widget.TextView;
import android.widget.Toast;

import com.automacia.mobile.R;
import com.automacia.mobile.adapters.PrescriptionAdapter;
import com.automacia.mobile.models.UsuarioDTO;

import java.util.ArrayList;
import java.util.List;

import de.hdodenhof.circleimageview.CircleImageView;

public class HomeFragment extends Fragment {

    // Views
    private TextView tvUserName, tvCpf, tvPrescriptionStatus;
    private CircleImageView ivProfile;
    private ImageButton btnHelp, btnLogout;
    private RecyclerView rvPrescriptions;
    private CardView cardHelp, cardSendPrescription, cardMessages;
    private CardView cardAllergies, cardMedicalHistory;
    private CardView[] quickActionCards = new CardView[7];

    // Dados do usuário
    private UsuarioDTO currentUser;
    private List<Prescription> prescriptionList;
    private PrescriptionAdapter prescriptionAdapter;

    // Constantes para argumentos
    private static final String ARG_USUARIO = "usuario";

    /**
     * Factory method para criar uma instância do Fragment com usuário
     */
    public static HomeFragment newInstance(UsuarioDTO usuario) {
        HomeFragment fragment = new HomeFragment();
        Bundle args = new Bundle();
        args.putSerializable(ARG_USUARIO, usuario);
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_home, container, false);

        // Recuperar usuário dos argumentos
        if (getArguments() != null) {
            currentUser = (UsuarioDTO) getArguments().getSerializable(ARG_USUARIO);
        }

        // Se não tiver usuário nos argumentos, tentar buscar de outro local
        if (currentUser == null) {
            currentUser = getUserFromSession(); // Método para buscar de SharedPreferences ou outro local
        }

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
        if (currentUser == null) {
            // Fallback: criar usuário vazio ou mostrar erro
            Toast.makeText(getContext(), "Erro ao carregar dados do usuário", Toast.LENGTH_LONG).show();
            return;
        }

        // Atualizar UI com dados do usuário real
        tvUserName.setText(currentUser.getNomeExibicao()); // Usa nome social ou nome normal
        tvCpf.setText(formatCpf(currentUser.getCpf())); // Formata o CPF

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

    /**
     * Método para buscar usuário de sessão (SharedPreferences, Singleton, etc.)
     * Implementar conforme a arquitetura do projeto
     */
    private UsuarioDTO getUserFromSession() {
        // TODO: Implementar busca do usuário da sessão
        // Exemplo com SharedPreferences:
        // SharedPreferences prefs = getContext().getSharedPreferences("user_session", Context.MODE_PRIVATE);
        // String cpf = prefs.getString("user_cpf", null);
        // if (cpf != null) {
        //     // Buscar usuário completo do banco ou cache
        // }

        // Por enquanto retorna null
        return null;
    }

    /**
     * Formata CPF para exibição (xxx.xxx.xxx-xx)
     */
    private String formatCpf(String cpf) {
        if (cpf == null || cpf.length() != 11) {
            return cpf; // Retorna original se não tiver 11 dígitos
        }

        return cpf.substring(0, 3) + "." +
                cpf.substring(3, 6) + "." +
                cpf.substring(6, 9) + "-" +
                cpf.substring(9, 11);
    }

    private void updatePrescriptionStatus() {
        // Aqui você faria uma chamada para a API para obter o status atual
        // Por enquanto usando dados fictícios
        String status = "Bem-vindo, " + (currentUser != null ? currentUser.getNomeExibicao() : "Usuário") + "!\n" +
                "Você possui 2 receitas válidas.\n" +
                "1 receita foi enviada para a farmácia.\n" +
                "Última atualização: 14/04/2025.";
        tvPrescriptionStatus.setText(status);
    }

    private List<Prescription> createSamplePrescriptions() {
        List<Prescription> prescriptions = new ArrayList<>();

        // TODO: pegar as receitas diretamente do banco usando o CPF do usuário atual
        // String cpfUsuario = currentUser != null ? currentUser.getCpf() : null;

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
                PrescriptionStatus.VALID
        ));

        prescriptions.add(new Prescription(
                "3",
                "Receita - Vitaminas",
                "Dr. Ana Lima",
                "25/03/2025",
                "Processada",
                PrescriptionStatus.EXPIRED
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
        // Limpar dados de sessão e voltar para tela de login
        if (currentUser != null) {
            currentUser.clearSensitiveData();
        }
        // TODO: Limpar SharedPreferences, voltar para LoginActivity
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
            // Usar telefone do usuário se disponível, senão usar padrão
            String phoneNumber = currentUser != null && currentUser.getTelefone() != null ?
                    currentUser.getTelefone() : "+5511999999999";

            Intent intent = new Intent(Intent.ACTION_DIAL);
            intent.setData(Uri.parse("tel:" + phoneNumber));
            startActivity(intent);
        } catch (Exception e) {
            Toast.makeText(getContext(), "Não foi possível abrir o discador", Toast.LENGTH_SHORT).show();
        }
    }

    private void openFAQ() {
        Toast.makeText(getContext(), "Abrindo FAQ...", Toast.LENGTH_SHORT).show();
        // Aqui você abriria a tela de FAQ
    }

    // Classes modelo (mantidas para compatibilidade)
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