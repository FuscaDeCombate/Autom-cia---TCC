package com.automacia.mobile.fragments;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.automacia.mobile.R;
import com.automacia.mobile.adapters.NotificationAdapter;
import com.automacia.mobile.models.Notification;
import com.automacia.mobile.utils.NotificationUtils;
import com.google.android.material.button.MaterialButton;
import java.util.List;
import java.util.Map;

public class NotificationFragment extends Fragment implements NotificationAdapter.OnNotificationClickListener {

    private SwipeRefreshLayout swipeRefreshLayout;
    private LinearLayout mainContent;
    private LinearLayout emptyStateLayout;
    private MaterialButton btnClearAll;

    // Seções de notificações
    private LinearLayout todaySection;
    private LinearLayout yesterdaySection;
    private LinearLayout thisWeekSection;
    private LinearLayout olderSection;

    // Títulos das seções
    private TextView tvToday;
    private TextView tvYesterday;
    private TextView tvThisWeek;
    private TextView tvOlder;

    // RecyclerViews para cada seção
    private RecyclerView rvToday;
    private RecyclerView rvYesterday;
    private RecyclerView rvThisWeek;
    private RecyclerView rvOlder;

    // Adapters
    private NotificationAdapter todayAdapter;
    private NotificationAdapter yesterdayAdapter;
    private NotificationAdapter thisWeekAdapter;
    private NotificationAdapter olderAdapter;

    // Dados
    private List<Notification> allNotifications;
    private Map<NotificationUtils.DateSection, List<Notification>> groupedNotifications;

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
        setupRecyclerViews();
        setupClickListeners();
        loadNotifications();
    }

    private void initViews(View view) {
        swipeRefreshLayout = view.findViewById(R.id.swipeRefreshLayout);
        emptyStateLayout = view.findViewById(R.id.emptyStateLayout);
        btnClearAll = view.findViewById(R.id.btnClearAll);

        // Criar seções dinamicamente
        createNotificationSections(view);
    }

    private void createNotificationSections(View parentView) {
        LinearLayout mainLinearLayout = parentView.findViewById(R.id.mainLinearLayout);

        // Criar seções programaticamente para ter controle total
        createSectionViews(mainLinearLayout);
    }

    private void createSectionViews(LinearLayout parent) {
        LayoutInflater inflater = LayoutInflater.from(getContext());

        // Seção Hoje
        todaySection = createSectionLayout(parent, "Hoje");
        rvToday = createRecyclerView();
        todaySection.addView(rvToday);

        // Seção Ontem
        yesterdaySection = createSectionLayout(parent, "Ontem");
        rvYesterday = createRecyclerView();
        yesterdaySection.addView(rvYesterday);

        // Seção Esta Semana
        thisWeekSection = createSectionLayout(parent, "Esta Semana");
        rvThisWeek = createRecyclerView();
        thisWeekSection.addView(rvThisWeek);

        // Seção Anteriores
        olderSection = createSectionLayout(parent, "Anteriores");
        rvOlder = createRecyclerView();
        olderSection.addView(rvOlder);
    }

    private LinearLayout createSectionLayout(LinearLayout parent, String title) {
        LinearLayout sectionLayout = new LinearLayout(getContext());
        sectionLayout.setOrientation(LinearLayout.VERTICAL);
        sectionLayout.setLayoutParams(new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
        ));

        // Título da seção
        TextView titleView = new TextView(getContext());
        titleView.setText(title);
        titleView.setTextSize(16);
        titleView.setTextColor(getResources().getColor(R.color.text_primary));
        titleView.setTypeface(null, android.graphics.Typeface.BOLD);

        LinearLayout.LayoutParams titleParams = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
        );
        titleParams.setMargins(
                (int) getResources().getDimension(R.dimen.margin_small),
                (int) getResources().getDimension(R.dimen.margin_medium),
                0,
                (int) getResources().getDimension(R.dimen.margin_small)
        );
        titleView.setLayoutParams(titleParams);

        sectionLayout.addView(titleView);
        parent.addView(sectionLayout);

        return sectionLayout;
    }

    private RecyclerView createRecyclerView() {
        RecyclerView recyclerView = new RecyclerView(getContext());
        recyclerView.setLayoutParams(new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
        ));
        recyclerView.setNestedScrollingEnabled(false);
        recyclerView.setLayoutManager(new LinearLayoutManager(getContext()));
        return recyclerView;
    }

    private void setupRecyclerViews() {
        LinearLayoutManager layoutManager1 = new LinearLayoutManager(getContext());
        layoutManager1.setAutoMeasureEnabled(true);
        rvToday.setLayoutManager(layoutManager1);
        rvToday.setHasFixedSize(false);

        LinearLayoutManager layoutManager2 = new LinearLayoutManager(getContext());
        layoutManager2.setAutoMeasureEnabled(true);
        rvYesterday.setLayoutManager(layoutManager2);
        rvYesterday.setHasFixedSize(false);

        LinearLayoutManager layoutManager3 = new LinearLayoutManager(getContext());
        layoutManager3.setAutoMeasureEnabled(true);
        rvThisWeek.setLayoutManager(layoutManager3);
        rvThisWeek.setHasFixedSize(false);

        LinearLayoutManager layoutManager4 = new LinearLayoutManager(getContext());
        layoutManager4.setAutoMeasureEnabled(true);
        rvOlder.setLayoutManager(layoutManager4);
        rvOlder.setHasFixedSize(false);
    }

    private void setupClickListeners() {
        btnClearAll.setOnClickListener(v -> clearAllNotifications());

        swipeRefreshLayout.setOnRefreshListener(this::refreshNotifications);
        swipeRefreshLayout.setColorSchemeResources(
                R.color.primary,
                R.color.primary_light
        );
    }

    private void loadNotifications() {
        // Simular carregamento de dados - substitua por chamada real da API
        allNotifications = NotificationUtils.generateSampleNotifications();
        updateNotificationSections();
    }

    private void refreshNotifications() {
        // Simular refresh - substitua por chamada real da API
        swipeRefreshLayout.setRefreshing(true);

        // Simular delay de rede
        new android.os.Handler().postDelayed(() -> {
            loadNotifications();
            swipeRefreshLayout.setRefreshing(false);
        }, 1000);
    }

    private void updateNotificationSections() {
        if (allNotifications == null || allNotifications.isEmpty()) {
            showEmptyState();
            return;
        }

        hideEmptyState();

        // Agrupar notificações por data
        groupedNotifications = NotificationUtils.groupNotificationsByDate(allNotifications);

        // Configurar adapters para cada seção
        setupSectionAdapter(NotificationUtils.DateSection.TODAY, rvToday, todaySection);
        setupSectionAdapter(NotificationUtils.DateSection.YESTERDAY, rvYesterday, yesterdaySection);
        setupSectionAdapter(NotificationUtils.DateSection.THIS_WEEK, rvThisWeek, thisWeekSection);
        setupSectionAdapter(NotificationUtils.DateSection.OLDER, rvOlder, olderSection);

        // Atualizar botão "Limpar Todas"
        updateClearAllButton();
    }

    private void setupSectionAdapter(NotificationUtils.DateSection section,
                                     RecyclerView recyclerView,
                                     LinearLayout sectionLayout) {
        List<Notification> sectionNotifications = groupedNotifications.get(section);

        if (sectionNotifications == null || sectionNotifications.isEmpty()) {
            sectionLayout.setVisibility(View.GONE);
            return;
        }

        sectionLayout.setVisibility(View.VISIBLE);

        NotificationAdapter adapter = new NotificationAdapter(getContext(), sectionNotifications);
        adapter.setOnNotificationClickListener(this);
        recyclerView.setAdapter(adapter);
    }

    private void showEmptyState() {
        emptyStateLayout.setVisibility(View.VISIBLE);
        swipeRefreshLayout.getChildAt(0).setVisibility(View.GONE);
        btnClearAll.setVisibility(View.GONE);
    }

    private void hideEmptyState() {
        emptyStateLayout.setVisibility(View.GONE);
        swipeRefreshLayout.getChildAt(0).setVisibility(View.VISIBLE);
    }

    private void updateClearAllButton() {
        int unreadCount = NotificationUtils.getUnreadCount(allNotifications);

        if (unreadCount > 0) {
            btnClearAll.setVisibility(View.VISIBLE);
            btnClearAll.setText(String.format("Limpar Todas (%d)", unreadCount));
        } else {
            btnClearAll.setText("Limpar Todas");
        }
    }

    private void clearAllNotifications() {
        if (allNotifications == null) return;

        // Marcar todas como lidas
        for (Notification notification : allNotifications) {
            notification.setRead(true);
        }

        // Atualizar adapters
        updateAllAdapters();
        updateClearAllButton();

        // Opcional: Mostrar feedback ao usuário
        if (getView() != null) {
            com.google.android.material.snackbar.Snackbar.make(
                    getView(),
                    "Todas as notificações foram marcadas como lidas",
                    com.google.android.material.snackbar.Snackbar.LENGTH_SHORT
            ).show();
        }
    }

    private void updateAllAdapters() {
        if (rvToday.getAdapter() != null) {
            rvToday.getAdapter().notifyDataSetChanged();
        }
        if (rvYesterday.getAdapter() != null) {
            rvYesterday.getAdapter().notifyDataSetChanged();
        }
        if (rvThisWeek.getAdapter() != null) {
            rvThisWeek.getAdapter().notifyDataSetChanged();
        }
        if (rvOlder.getAdapter() != null) {
            rvOlder.getAdapter().notifyDataSetChanged();
        }
    }

    @Override
    public void onNotificationClick(Notification notification, int position) {
        // Lógica para quando uma notificação é clicada
        // Aqui você pode navegar para telas específicas baseado no tipo da notificação

        switch (notification.getType()) {
            case PRESCRIPTION_EXPIRING:
                // Navegar para tela de renovação de receita
                handlePrescriptionExpiring(notification);
                break;
            case NEW_PRESCRIPTION:
                // Navegar para tela de receitas
                handleNewPrescription(notification);
                break;
            case MEDICATION_REMINDER:
                // Navegar para tela de medicamentos
                handleMedicationReminder(notification);
                break;
            case PHARMACY_READY:
                // Navegar para tela da farmácia/pedidos
                handlePharmacyReady(notification);
                break;
            case SYSTEM_UPDATE:
                // Mostrar dialog de atualização ou navegar para configurações
                handleSystemUpdate(notification);
                break;
            case APPOINTMENT_REMINDER:
                // Navegar para tela de consultas
                handleAppointmentReminder(notification);
                break;
            default:
                // Ação padrão
                handleGeneralNotification(notification);
                break;
        }

        // Atualizar contador após marcar como lida
        updateClearAllButton();
    }

    private void handlePrescriptionExpiring(Notification notification) {
        // TODO: Implementar navegação para tela de renovação de receita
        showNotificationAction("Abrindo renovação de receita...");
    }

    private void handleNewPrescription(Notification notification) {
        // TODO: Implementar navegação para tela de receitas
        showNotificationAction("Abrindo receita...");
    }

    private void handleMedicationReminder(Notification notification) {
        // TODO: Implementar navegação para tela de medicamentos
        showNotificationAction("Abrindo medicamentos...");
    }

    private void handlePharmacyReady(Notification notification) {
        // TODO: Implementar navegação para tela de pedidos/farmácia
        showNotificationAction("Abrindo pedidos...");
    }

    private void handleSystemUpdate(Notification notification) {
        // TODO: Implementar dialog de atualização ou configurações
        showNotificationAction("Verificando atualizações...");
    }

    private void handleAppointmentReminder(Notification notification) {
        // TODO: Implementar navegação para tela de consultas
        showNotificationAction("Abrindo consultas...");
    }

    private void handleGeneralNotification(Notification notification) {
        // TODO: Implementar ação padrão
        showNotificationAction("Abrindo detalhes...");
    }

    private void showNotificationAction(String message) {
        if (getView() != null) {
            com.google.android.material.snackbar.Snackbar.make(
                    getView(),
                    message,
                    com.google.android.material.snackbar.Snackbar.LENGTH_SHORT
            ).show();
        }
    }

    // Método público para atualizar notificações externamente
    public void updateNotifications(List<Notification> newNotifications) {
        this.allNotifications = newNotifications;
        updateNotificationSections();
    }

    // Método público para obter contagem de notificações não lidas
    public int getUnreadNotificationCount() {
        if (allNotifications == null) return 0;
        return NotificationUtils.getUnreadCount(allNotifications);
    }

    // Método público para marcar uma notificação específica como lida
    public void markNotificationAsRead(int notificationId) {
        if (allNotifications == null) return;

        for (Notification notification : allNotifications) {
            if (notification.getId() == notificationId) {
                notification.setRead(true);
                break;
            }
        }

        updateAllAdapters();
        updateClearAllButton();
    }

    @Override
    public void onResume() {
        super.onResume();
        // Opcional: Refresh automático quando o fragment volta ao primeiro plano
        // loadNotifications();
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        // Cleanup se necessário
        if (todayAdapter != null) todayAdapter.setOnNotificationClickListener(null);
        if (yesterdayAdapter != null) yesterdayAdapter.setOnNotificationClickListener(null);
        if (thisWeekAdapter != null) thisWeekAdapter.setOnNotificationClickListener(null);
        if (olderAdapter != null) olderAdapter.setOnNotificationClickListener(null);
    }
}