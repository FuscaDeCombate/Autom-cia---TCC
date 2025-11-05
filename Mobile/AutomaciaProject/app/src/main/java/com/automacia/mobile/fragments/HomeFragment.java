package com.automacia.mobile.fragments;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.cardview.widget.CardView;

import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import com.automacia.mobile.quickactions.FullPrescriptionsActivity;
import com.automacia.mobile.MyApp;
import com.automacia.mobile.R;
import com.automacia.mobile.adapters.TimelinePrescriptionAdapter;
import com.automacia.mobile.models.PrescriptionDTO;
import com.automacia.mobile.models.UsuarioDTO;
import com.automacia.mobile.quickactions.FuncionarioChat;
import com.automacia.mobile.quickactions.MedicalHistoryActivity;
import com.automacia.mobile.quickactions.Pharmacys;
import com.automacia.mobile.services.PrescriptionService;
import com.automacia.mobile.utils.Utils;

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
    private CardView cardMedicalHistory;
    private LinearLayout quickMedicos, quickFarmacias, quickEmergencias, quickRelatorio;

    // Dados do usuário
    private UsuarioDTO currentUser;
    private List<PrescriptionDTO> prescriptionList;
    private TimelinePrescriptionAdapter prescriptionAdapter;

    // Service
    private PrescriptionService prescriptionService;

    // Constantes para argumentos
    private static final String ARG_USUARIO = "usuario";

    // Flag para controlar se já carregou dados
    private boolean hasLoadedData = false;

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

        // Carregar receitas do banco de dados apenas na primeira vez
        if (!hasLoadedData) {
            loadPrescriptionsFromDatabase();
            hasLoadedData = true;
        }

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

        // Seções principais
        cardMedicalHistory = view.findViewById(R.id.card_medical_history);

        // RecyclerView para receitas
        rvPrescriptions = view.findViewById(R.id.rv_prescriptions);
        // Ações rápidas
        quickMedicos = view.findViewById(R.id.quick_action_medicos);
        quickFarmacias = view.findViewById(R.id.quick_action_farmacias);
        quickEmergencias = view.findViewById(R.id.quick_action_emergencias);
        quickRelatorio = view.findViewById(R.id.quick_action_relatorios);

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
        tvCpf.setText(Utils.formatCpf(currentUser.getCpf()));

        // Status inicial - removido o "Carregando suas receitas..." daqui
        // Será definido em loadPrescriptionsFromDatabase()
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

        // Seções principais
        cardMedicalHistory.setOnClickListener(v -> openMedicalHistory());

        // Ações rápidas
        quickMedicos.setOnClickListener(v -> openChatDoctors());
        quickFarmacias.setOnClickListener(v -> openPharmacys());
        quickEmergencias.setOnClickListener(v -> openEmergnecyTab());
        quickRelatorio.setOnClickListener(v -> openStatistics());
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
        tvPrescriptionStatus.setText("Carregando suas receitas...");

        // Buscar receitas SIMPLES (apenas dados necessários para o adapter)
        prescriptionService.fetchSimplePrescription(currentUser.getCpf(), new PrescriptionService.PrescriptionCallback() {
            @Override
            public void onSuccess(List<PrescriptionDTO> prescriptions) {
                // Verificar se o fragment ainda está anexado
                if (!isAdded() || getContext() == null) {
                    return;
                }

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
                // Verificar se o fragment ainda está anexado
                if (!isAdded() || getContext() == null) {
                    return;
                }

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
        try {
            MyApp app = (MyApp) requireActivity().getApplicationContext();
            UsuarioDTO user = app.getUsuarioLogado();

            if (user != null) {
                Log.d("HomeFragment", "Usuário carregado: " + user.getNomeExibicao());
                return user;
            } else {
                Log.e("HomeFragment", "Usuário não encontrado no MyApp");
            }
        } catch (Exception e) {
            Log.e("HomeFragment", "Erro ao buscar usuário da sessão", e);
        }
        return null;
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
    }

    private void openMedicalHistory() {
        if (getActivity() == null) {
            Log.e("HomeFragment", "openMedicalHistory() chamado, mas Activity é nula");
            return;
        }

        if (currentUser == null) {
            Toast.makeText(getContext(), "Usuário não encontrado", Toast.LENGTH_SHORT).show();
            Log.e("HomeFragment", "currentUser está null em openMedicalHistory()");
            return;
        }

        Intent intent = new Intent(getActivity().getBaseContext(), MedicalHistoryActivity.class);
        intent.putExtra("usuario", currentUser);

        startActivity(intent);

        // Animação de fade in / fade out
        getActivity().overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
    }

    private void openPrescriptionDetails(PrescriptionDTO prescription) {
        Toast.makeText(getContext(),
                "Abrindo detalhes: " + prescription.getMedicamento(),
                Toast.LENGTH_SHORT).show();
        // TODO: Abrir Activity com detalhes completos
        // Você pode usar prescriptionService.fetchPrescriptionById() ou fetchCompletePrescriptions()
    }

    private void viewAllPrescriptions() {
        Log.d("HomeFragment", "Abrindo tela de todas as receitas");

        if (currentUser == null) {
            Log.e("HomeFragment", "Usuário não encontrado ao tentar abrir receitas");
            return;
        }

        Intent intent = new Intent(getActivity(), FullPrescriptionsActivity.class);
        intent.putExtra("usuario", currentUser);
        startActivity(intent);
    }

    private void openPharmacys() {
        Intent intent = new Intent(getActivity().getBaseContext(), Pharmacys.class);
        startActivity(intent);

        // Animação de fade in / fade out
        getActivity().overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
    }

    private void openChatDoctors() {
        if (currentUser == null) {
            Log.e("HomeFragment", "Usuário não encontrado ao tentar abrir receitas");
            return;
        }

        Intent intent = new Intent(getActivity().getBaseContext(), FuncionarioChat.class);
        intent.putExtra("usuario", currentUser);
        startActivity(intent);

        getActivity().overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
    }

    private void openEmergnecyTab() {

    }

    private void openStatistics() {

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

    /**
     * Recarrega os dados do usuário da sessão
     */
    private void reloadUserData() {
        Log.d("HomeFragment", "=== Iniciando reload dos dados do usuário ===");

        try {
            // Buscar usuário atualizado da sessão
            UsuarioDTO updatedUser = getUserFromSession();

            if (updatedUser != null) {
                Log.d("HomeFragment", "Usuário encontrado: " + updatedUser.getNomeExibicao());
                Log.d("HomeFragment", "CPF: " + updatedUser.getCpf());

                // Verificar se houve mudanças
                boolean dadosMudaram = false;
                if (currentUser != null) {
                    dadosMudaram = !currentUser.getNomeExibicao().equals(updatedUser.getNomeExibicao()) ||
                            !currentUser.getCpf().equals(updatedUser.getCpf());

                    if (dadosMudaram) {
                        Log.d("HomeFragment", "Dados do usuário foram alterados!");
                    } else {
                        Log.d("HomeFragment", "Dados do usuário não mudaram");
                    }
                }

                currentUser = updatedUser;
                setupUserData();

                // Recarregar as receitas se os dados mudaram ou se é a primeira carga
                if (dadosMudaram || prescriptionList == null || prescriptionList.isEmpty()) {
                    Log.d("HomeFragment", "Recarregando receitas do banco de dados");
                    loadPrescriptionsFromDatabase();
                }
            } else {
                Log.e("HomeFragment", "Usuário atualizado é NULL");
                Toast.makeText(getContext(),
                        "Erro ao atualizar dados do usuário",
                        Toast.LENGTH_SHORT).show();
            }
        } catch (Exception e) {
            Log.e("HomeFragment", "Erro ao recarregar dados do usuário", e);
            Toast.makeText(getContext(),
                    "Erro ao atualizar dados: " + e.getMessage(),
                    Toast.LENGTH_SHORT).show();
        }

        Log.d("HomeFragment", "=== Fim do reload dos dados ===");
    }

    @Override
    public void onHiddenChanged(boolean hidden) {
        super.onHiddenChanged(hidden);
        if (!hidden) {
            // Fragment ficou visível
            Log.d("HomeFragment", "onHiddenChanged() - Fragment ficou visível");
            reloadUserData();
        }
    }

    /**
     * Metodo público para forçar recarga (pode ser chamado pela MainActivity se necessário)
     */
    public void forceReload() {
        Log.d("HomeFragment", "forceReload() - Recarga forçada solicitada");
        reloadUserData();
    }
}