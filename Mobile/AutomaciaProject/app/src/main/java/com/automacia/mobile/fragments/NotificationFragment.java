package com.automacia.mobile.fragments;

import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;
import com.automacia.mobile.R;
import com.automacia.mobile.adapters.NotificationAdapter;
import com.automacia.mobile.managers.AppNotificationManager;
import com.automacia.mobile.models.NotificationDTO;
import com.automacia.mobile.models.NotificationItem;
import com.automacia.mobile.storage.NotificationStorage;
import com.automacia.mobile.utils.NotificationUtils;
import com.google.android.material.button.MaterialButton;
import com.google.android.material.floatingactionbutton.FloatingActionButton;
import com.google.android.material.snackbar.Snackbar;
import java.util.List;
import java.util.Map;

/**
 * Fragment refatorado com:
 * - RecyclerView único com ViewTypes
 * - Persistência com NotificationStorage
 * - DiffUtil para updates eficientes
 * - Estados de UI (loading, empty, content)
 */
public class NotificationFragment extends Fragment implements NotificationAdapter.OnNotificationClickListener {

    // Views
    private SwipeRefreshLayout swipeRefreshLayout;
    private LinearLayout mainContent;
    private LinearLayout emptyStateLayout;
    private LinearLayout loadingLayout;
    private RecyclerView rvNotifications;
    private MaterialButton btnMarkAllRead;

    // Adapter e dados
    private NotificationAdapter adapter;
    private NotificationStorage storage;
    private List<NotificationDTO> allNotifications;

    public NotificationFragment() {
        // Required empty public constructor
    }

    public static NotificationFragment newInstance() {
        return new NotificationFragment();
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.fragment_notification, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        initViews(view);
        setupRecyclerView();
        setupClickListeners();
        loadNotifications();
        setuptestFAB(view);
    }

    // TODO: Remover essa funcionalidade em produção
    private void setuptestFAB(View view) {
        FloatingActionButton btnTestNotification = view.findViewById(R.id.btnTestNotification);
        btnTestNotification.setOnClickListener(v -> {
            // Criar notificação de teste usando o NotificationManager
            AppNotificationManager manager = AppNotificationManager.getInstance(requireContext());

            NotificationDTO testNotification = manager.notifyGeneral(
                    "🧪 Notificação de Teste",
                    "Esta é uma notificação temporária para testes. Será removida em 10 segundos."
            );

            showSnackbar("Notificação de teste criada!");

            // Recarregar o Fragment para mostrar a nova notificação
            loadNotifications();

            // Remover automaticamente após 10 segundos
            new Handler(Looper.getMainLooper()).postDelayed(() -> {
                manager.removeNotification(testNotification.getId());
                loadNotifications(); // Atualizar Fragment novamente
                showSnackbar("Notificação de teste removida");
            }, 10000); // 10 segundos
        });
    }

    private void initViews(View view) {
        swipeRefreshLayout = view.findViewById(R.id.swipeRefreshLayout);
        mainContent = view.findViewById(R.id.mainContent);
        emptyStateLayout = view.findViewById(R.id.emptyStateLayout);
        loadingLayout = view.findViewById(R.id.loadingLayout);
        rvNotifications = view.findViewById(R.id.rvNotifications);
        btnMarkAllRead = view.findViewById(R.id.btnMarkAllRead);

        // Inicializar storage
        storage = new NotificationStorage(requireContext());
    }

    private void setupRecyclerView() {
        adapter = new NotificationAdapter(requireContext());
        adapter.setOnNotificationClickListener(this);

        rvNotifications.setLayoutManager(new LinearLayoutManager(requireContext()));
        rvNotifications.setAdapter(adapter);
        rvNotifications.setHasFixedSize(false);
    }

    private void setupClickListeners() {
        btnMarkAllRead.setOnClickListener(v -> markAllAsRead());

        swipeRefreshLayout.setOnRefreshListener(this::refreshNotifications);
        swipeRefreshLayout.setColorSchemeResources(
                R.color.primary,
                R.color.primary_light
        );
    }

    private void loadNotifications() {
        showLoading();

        // Simular delay de carregamento (remover em produção)
        new Handler().postDelayed(() -> {
            // Carregar do storage
            allNotifications = storage.loadNotifications();

            // Se vazio, gerar dados de exemplo (APENAS PARA TESTE)
            if (allNotifications.isEmpty()) {
                allNotifications = NotificationUtils.generateSampleNotifications();
                storage.saveNotifications(allNotifications);
            }

            updateUI();
        }, 500);
    }

    private void refreshNotifications() {
        new Handler().postDelayed(() -> {
            allNotifications = storage.loadNotifications();
            updateUI();
            swipeRefreshLayout.setRefreshing(false);

            showSnackbar("Notificações atualizadas");
        }, 1000);
    }

    private void updateUI() {
        if (allNotifications == null || allNotifications.isEmpty()) {
            showEmptyState();
            return;
        }

        showContent();

        // Agrupar notificações por data
        Map<NotificationUtils.DateSection, List<NotificationDTO>> groupedNotifications =
                NotificationUtils.groupNotificationsByDate(allNotifications);

        // Converter para lista plana com headers
        List<NotificationItem> flatList = NotificationUtils.convertToFlatList(groupedNotifications);

        // Atualizar adapter com DiffUtil
        adapter.updateItems(flatList);

        // Atualizar botão
        updateMarkAllReadButton();
    }

    private void updateMarkAllReadButton() {
        int unreadCount = NotificationUtils.getUnreadCount(allNotifications);

        if (unreadCount > 0) {
            btnMarkAllRead.setVisibility(View.VISIBLE);
            btnMarkAllRead.setText(String.format("Marcar todas lidas (%d)", unreadCount));
        } else {
            btnMarkAllRead.setVisibility(View.GONE);
        }
    }

    private void markAllAsRead() {
        if (allNotifications == null || allNotifications.isEmpty()) return;

        // Marcar todas como lidas
        storage.markAllAsRead();

        // Recarregar
        allNotifications = storage.loadNotifications();
        updateUI();

        showSnackbar("Todas as notificações foram marcadas como lidas");
    }

    @Override
    public void onNotificationClick(NotificationDTO notification, int position) {
        // Marcar como lida
        if (!notification.isRead()) {
            notification.setRead(true);
            storage.markAsRead(notification.getId());

            // Recarregar lista
            allNotifications = storage.loadNotifications();
            updateUI();
        }

        // Navegar baseado no tipo
        handleNotificationNavigation(notification);
    }

    private void handleNotificationNavigation(NotificationDTO notification) {
        String message;

        switch (notification.getType()) {
            case PRESCRIPTION_EXPIRING:
                message = "Abrindo renovação de receita...";
                // TODO: navegar para tela de renovação
                break;
            case NEW_PRESCRIPTION:
                message = "Abrindo receita...";
                // TODO: navegar para tela de receitas
                break;
            case MEDICATION_REMINDER:
                message = "Abrindo medicamentos...";
                // TODO: navegar para tela de medicamentos
                break;
            case PHARMACY_READY:
                message = "Abrindo pedidos...";
                // TODO: navegar para tela de pedidos
                break;
            case SYSTEM_UPDATE:
                message = "Verificando atualizações...";
                // TODO: mostrar dialog de atualização
                break;
            case APPOINTMENT_REMINDER:
                message = "Abrindo consultas...";
                // TODO: navegar para tela de consultas
                break;
            case NEW_MESSAGE:
                message = "Abrindo mensagens...";
                // TODO: navegar para tela de mensagens
                break;
            default:
                message = "Abrindo detalhes...";
                break;
        }

        showSnackbar(message);
    }

    // ========== Controle de estados da UI ==========

    private void showLoading() {
        loadingLayout.setVisibility(View.VISIBLE);
        mainContent.setVisibility(View.GONE);
        emptyStateLayout.setVisibility(View.GONE);
    }

    private void showContent() {
        loadingLayout.setVisibility(View.GONE);
        mainContent.setVisibility(View.VISIBLE);
        emptyStateLayout.setVisibility(View.GONE);
    }

    private void showEmptyState() {
        loadingLayout.setVisibility(View.GONE);
        mainContent.setVisibility(View.GONE);
        emptyStateLayout.setVisibility(View.VISIBLE);
    }

    private void showSnackbar(String message) {
        if (getActivity() == null) return;

        View rootView = getActivity().findViewById(android.R.id.content);
        Snackbar snackbar = Snackbar.make(rootView, message, Snackbar.LENGTH_SHORT);

        // Se o seu BottomNavigationView tiver um ID conhecido:
        View bottomNav = getActivity().findViewById(R.id.bottomNavigation);

        if (bottomNav != null) {
            snackbar.setAnchorView(bottomNav); // faz o snackbar subir acima do bottom nav
        }

        snackbar.show();
    }

    // ========== Métodos públicos para integração externa ==========

    /**
     * Atualiza notificações externamente (ex: após chamada de API)
     */
    public void updateNotifications(List<NotificationDTO> newNotifications) {
        this.allNotifications = newNotifications;
        storage.saveNotifications(newNotifications);
        updateUI();
    }

    /**
     * Retorna contagem de notificações não lidas
     */
    public int getUnreadNotificationCount() {
        if (allNotifications == null) return 0;
        return NotificationUtils.getUnreadCount(allNotifications);
    }

    /**
     * Adiciona uma nova notificação
     */
    public void addNotification(NotificationDTO notification) {
        storage.addNotification(notification);
        allNotifications = storage.loadNotifications();
        updateUI();
    }

    /**
     * Remove uma notificação específica
     */
    public void removeNotification(int notificationId) {
        storage.removeNotification(notificationId);
        allNotifications = storage.loadNotifications();
        updateUI();
    }

    // ========== Lifecycle ==========

    @Override
    public void onResume() {
        super.onResume();
        // Opcional: recarregar ao voltar para o fragment
        // refreshNotifications();
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        // Cleanup
        if (adapter != null) {
            adapter.setOnNotificationClickListener(null);
        }
    }
}