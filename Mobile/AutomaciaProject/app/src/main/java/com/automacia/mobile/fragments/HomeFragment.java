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
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import com.automacia.mobile.R;
import com.automacia.mobile.adapters.TimelinePrescriptionAdapter;
import com.automacia.mobile.models.PrescriptionDTO;
import com.automacia.mobile.models.UsuarioDTO;
import com.automacia.mobile.services.PrescriptionService;

import java.util.ArrayList;
import java.util.List;

import de.hdodenhof.circleimageview.CircleImageView;

public class HomeFragment extends Fragment {

    // Views
    private TextView tvUserName, tvCpf, tvPrescriptionStatus;
    private CircleImageView ivProfile;
    private ImageButton btnHelp, btnLogout;
    private RecyclerView rvPrescriptions;
    private ProgressBar progressBar;
    private CardView cardHelp, cardSendPrescription, cardMessages;
    private CardView cardAllergies, cardMedicalHistory;
    private CardView[] quickActionCards = new CardView[7];

    // Dados do usuário
    private UsuarioDTO currentUser;
    private List<PrescriptionDTO> prescriptionList;
    private TimelinePrescriptionAdapter prescriptionAdapter;

    // Service
    private PrescriptionService prescriptionService;

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

        // Inicializar service
        prescriptionService = new PrescriptionService();

        // Recuperar usuário dos argumentos
        if (getArguments() != null) {
            currentUser = (UsuarioDTO) getArguments().getSerializable(ARG_USUARIO);
        }

        // Se não tiver usuário nos argumentos, tentar buscar de outro local
        if (currentUser == null) {
            currentUser = getUserFromSession();
        }

        initViews(view);
        setupUserData();
        setupRecyclerView();
        setupClickListeners();

        // Carregar receitas do banco de dados
        loadPrescriptionsFromDatabase();

        return view;
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        // Encerrar o service quando o fragment for destruído
        if (prescriptionService != null) {
            prescriptionService.shutdown();
        }
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

        // ProgressBar
        progressBar = view.findViewById(R.id.progressBar);

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
            Toast.makeText(getContext(), "Erro ao carregar dados do usuário", Toast.LENGTH_LONG).show();
            return;
        }

        // Atualizar UI com dados do usuário real
        tvUserName.setText(currentUser.getNomeExibicao());
        tvCpf.setText(formatCpf(currentUser.getCpf()));

        // Status inicial (será atualizado após carregar as receitas)
        tvPrescriptionStatus.setText("Carregando suas receitas...");
    }

    private void setupRecyclerView() {
        // Inicializar com lista vazia
        prescriptionList = new ArrayList<>();

        prescriptionAdapter = new TimelinePrescriptionAdapter(prescriptionList, prescription -> {
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
     * Carrega as receitas do banco de dados usando PrescriptionService
     */
    private void loadPrescriptionsFromDatabase() {
        if (currentUser == null || currentUser.getCpf() == null) {
            Toast.makeText(getContext(), "CPF do usuário não encontrado", Toast.LENGTH_SHORT).show();
            tvPrescriptionStatus.setText("Erro ao carregar receitas");
            return;
        }

        // Mostrar loading
        showLoading(true);

        // Buscar receitas SIMPLES (apenas dados necessários para o adapter)
        prescriptionService.fetchSimplePrescription(currentUser.getCpf(), new PrescriptionService.PrescriptionCallback() {
            @Override
            public void onSuccess(List<PrescriptionDTO> prescriptions) {
                showLoading(false);

                if (prescriptions == null || prescriptions.isEmpty()) {
                    // Nenhuma receita encontrada
                    prescriptionList.clear();
                    prescriptionAdapter.updatePrescriptions(prescriptionList);
                    updatePrescriptionStatusEmpty();
                    Toast.makeText(getContext(), "Nenhuma receita encontrada", Toast.LENGTH_SHORT).show();
                    return;
                }

                // Atualizar lista e adapter
                prescriptionList.clear();
                prescriptionList.addAll(prescriptions);
                prescriptionAdapter.updatePrescriptions(prescriptionList);

                // Atualizar status com dados reais
                updatePrescriptionStatus(prescriptions);

                Toast.makeText(getContext(),
                        prescriptions.size() + " receita(s) carregada(s)",
                        Toast.LENGTH_SHORT).show();
            }

            @Override
            public void onError(String errorMessage) {
                showLoading(false);

                // Mostrar erro básico para o usuário
                Toast.makeText(getContext(),
                        "Erro ao carregar receitas",
                        Toast.LENGTH_LONG).show();

                // Log detalhado já está no PrescriptionService
                tvPrescriptionStatus.setText("Erro ao carregar receitas.\nTente novamente mais tarde.");
            }
        });
    }

    /**
     * Mostra/esconde o loading
     */
    private void showLoading(boolean show) {
        if (progressBar != null) {
            progressBar.setVisibility(show ? View.VISIBLE : View.GONE);
        }
        if (rvPrescriptions != null) {
            rvPrescriptions.setVisibility(show ? View.GONE : View.VISIBLE);
        }
    }

    /**
     * Atualiza o status das receitas com dados reais do banco
     */
    private void updatePrescriptionStatus(List<PrescriptionDTO> prescriptions) {
        if (prescriptions == null || prescriptions.isEmpty()) {
            updatePrescriptionStatusEmpty();
            return;
        }

        // Contar receitas válidas e enviadas
        int validCount = 0;
        int sentCount = 0; // Você pode adicionar lógica para identificar receitas "enviadas"

        for (PrescriptionDTO prescription : prescriptions) {
            if (prescription.isValido()) {
                validCount++;
            }
            // Se você tiver um campo de status "enviada", conte aqui
        }

        // Montar texto do status
        StringBuilder statusText = new StringBuilder();
        statusText.append("Bem-vindo, ").append(currentUser.getNomeExibicao()).append("!\n");

        if (validCount > 0) {
            statusText.append("Você possui ").append(validCount)
                    .append(validCount == 1 ? " receita válida" : " receitas válidas").append(".\n");
        } else {
            statusText.append("Você não possui receitas válidas no momento.\n");
        }

        statusText.append("Total de receitas: ").append(prescriptions.size());

        tvPrescriptionStatus.setText(statusText.toString());
    }

    /**
     * Atualiza status quando não há receitas
     */
    private void updatePrescriptionStatusEmpty() {
        String status = "Bem-vindo, " + currentUser.getNomeExibicao() + "!\n" +
                "Você ainda não possui receitas cadastradas.\n" +
                "Solicite uma receita ao seu médico.";
        tvPrescriptionStatus.setText(status);
    }

    /**
     * Metodo para buscar usuário de sessão (SharedPreferences, Singleton, etc.)
     */
    private UsuarioDTO getUserFromSession() {
        // TODO: Implementar busca do usuário da sessão
        return null;
    }

    /**
     * Formata CPF para exibição (xxx.xxx.xxx-xx)
     */
    private String formatCpf(String cpf) {
        if (cpf == null || cpf.length() != 11) {
            return cpf;
        }

        return cpf.substring(0, 3) + "." +
                cpf.substring(3, 6) + "." +
                cpf.substring(6, 9) + "-" +
                cpf.substring(9, 11);
    }

    // Métodos de ação
    private void showHelp() {
        Toast.makeText(getContext(), "Abrindo central de ajuda...", Toast.LENGTH_SHORT).show();
    }

    private void logout() {
        Toast.makeText(getContext(), "Fazendo logout...", Toast.LENGTH_SHORT).show();
        if (currentUser != null) {
            currentUser.clearSensitiveData();
        }
        // TODO: Limpar SharedPreferences, voltar para LoginActivity
    }

    private void sendPrescription() {
        Toast.makeText(getContext(), "Abrindo envio de receita...", Toast.LENGTH_SHORT).show();
    }

    private void openMessages() {
        Toast.makeText(getContext(), "Abrindo mensagens...", Toast.LENGTH_SHORT).show();
    }

    private void openAllergies() {
        Toast.makeText(getContext(), "Abrindo alergias...", Toast.LENGTH_SHORT).show();
    }

    private void openMedicalHistory() {
        Toast.makeText(getContext(), "Abrindo histórico médico...", Toast.LENGTH_SHORT).show();
    }

    private void openPrescriptionDetails(PrescriptionDTO prescription) {
        Toast.makeText(getContext(),
                "Abrindo detalhes: " + prescription.getMedicamento(),
                Toast.LENGTH_SHORT).show();
        // TODO: Abrir Activity com detalhes completos
        // Você pode usar prescriptionService.fetchPrescriptionById() ou fetchCompletePrescriptions()
    }

    private void viewAllPrescriptions() {
        Toast.makeText(getContext(), "Abrindo todas as receitas...", Toast.LENGTH_SHORT).show();
        // TODO: Abrir Activity com todas as receitas
    }

    private void handleQuickAction(int actionIndex) {
        String[] actions = {
                "Médicos", "Farmácias", "Agendamentos", "Relatórios",
                "Consultas", "Configurações", "Favoritos"
        };

        if (actionIndex < actions.length) {
            Toast.makeText(getContext(), "Abrindo: " + actions[actionIndex], Toast.LENGTH_SHORT).show();
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
    }
}