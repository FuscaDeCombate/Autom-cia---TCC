package com.automacia.mobile;

import android.os.Bundle;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;

import com.automacia.mobile.databinding.ActivityMainBinding;
import com.nafis.bottomnavigation.NafisBottomNavigation;

import kotlin.Unit;
import kotlin.jvm.functions.Function1;

public class MainActivity extends AppCompatActivity {

    private ActivityMainBinding binding;
    private FragmentManager fragmentManager;

    // IDs para os itens da navegação
    private static final int ID_HOME = 1;
    private static final int ID_CHAT = 2;
    private static final int ID_NOTIF = 3;
    private static final int ID_PREF = 4;
    private static final int ID_USER = 5;

    // Variável para controlar o item selecionado
    private int currentSelectedId = ID_HOME;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);

        binding = ActivityMainBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        fragmentManager = getSupportFragmentManager();

        setupWindowInsets();
        setupNafisBottomNavigation();

        // Carrega fragment inicial apenas se não houver estado salvo
        if (savedInstanceState == null) {
            replaceFragment(new HomeFragment());
            binding.bottomNavigation.show(ID_HOME, true);
        }
    }

    private void setupWindowInsets() {
        ViewCompat.setOnApplyWindowInsetsListener(binding.main, (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });
    }

    private void setupNafisBottomNavigation() {
        // Adiciona os itens do menu à navegação
        binding.bottomNavigation.add(new NafisBottomNavigation.Model(ID_HOME, R.drawable.ic_home));
        binding.bottomNavigation.add(new NafisBottomNavigation.Model(ID_CHAT, R.drawable.ic_chat));
        binding.bottomNavigation.add(new NafisBottomNavigation.Model(ID_NOTIF, R.drawable.ic_notifications));
        binding.bottomNavigation.add(new NafisBottomNavigation.Model(ID_PREF, R.drawable.ic_settings));
        binding.bottomNavigation.add(new NafisBottomNavigation.Model(ID_USER, R.drawable.ic_person));

        // Listener para quando um item é clicado
        binding.bottomNavigation.setOnClickMenuListener(new Function1<NafisBottomNavigation.Model, Unit>() {
            @Override
            public Unit invoke(NafisBottomNavigation.Model model) {
                handleNavigationClick(model.getId());
                return null;
            }
        });

        // Listener para quando um item é mostrado (opcional para logs/analytics)
        binding.bottomNavigation.setOnShowListener(new Function1<NafisBottomNavigation.Model, Unit>() {
            @Override
            public Unit invoke(NafisBottomNavigation.Model model) {
                currentSelectedId = model.getId();
                // Aqui você pode adicionar logs ou analytics
                return null;
            }
        });

        // Listener para quando um item já selecionado é clicado novamente
        binding.bottomNavigation.setOnReselectListener(new Function1<NafisBottomNavigation.Model, Unit>() {
            @Override
            public Unit invoke(NafisBottomNavigation.Model model) {
                // Aqui você pode implementar ação para re-seleção
                // Por exemplo: scroll to top, refresh, etc.
                handleReselectAction(model.getId());
                return null;
            }
        });

        // Exemplo: adicionar badge de notificação (opcional)
        // binding.bottomNavigation.setCount(ID_NOTIF, "5");
    }

    private void handleNavigationClick(int itemId) {
        Fragment selectedFragment = null;

        switch (itemId) {
            case ID_HOME:
                selectedFragment = new HomeFragment();
                break;
            case ID_CHAT:
                selectedFragment = new ChatFragment();
                break;
            case ID_NOTIF:
                selectedFragment = new NotificationFragment();
                // Limpa o badge quando visualizar notificações
                binding.bottomNavigation.clearCount(ID_NOTIF);
                break;
            case ID_PREF:
                selectedFragment = new PreferencesFragment();
                break;
            case ID_USER:
                selectedFragment = new UserFragment();
                break;
        }

        if (selectedFragment != null) {
            replaceFragment(selectedFragment);
        }
    }

    private void handleReselectAction(int itemId) {
        // Ações para quando um item já selecionado é clicado novamente
        switch (itemId) {
            case ID_HOME:
                // Por exemplo: scroll to top na home
                break;
            case ID_CHAT:
                // Por exemplo: ir para o topo da lista de chats
                break;
            case ID_NOTIF:
                // Por exemplo: refresh das notificações
                break;
            case ID_PREF:
                // Por exemplo: não fazer nada ou mostrar uma mensagem
                break;
            case ID_USER:
                // Por exemplo: refresh do perfil
                break;
        }
    }

    private void replaceFragment(Fragment fragment) {
        if (fragment == null) return;

        String tag = fragment.getClass().getSimpleName();

        // Verifica se o fragment já existe para evitar recriações desnecessárias
        Fragment existingFragment = fragmentManager.findFragmentByTag(tag);
        Fragment targetFragment = existingFragment != null ? existingFragment : fragment;

        FragmentTransaction transaction = fragmentManager.beginTransaction();

        // Adiciona animação suave de transição
        transaction.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_FADE);

        // Substitui o fragment
        transaction.replace(R.id.flFragment, targetFragment, tag);

        // Não adiciona ao backstack para navigation tabs
        // transaction.addToBackStack(null);

        transaction.commit();
    }

    // Método público para programaticamente navegar para um item específico
    public void navigateToItem(int itemId) {
        binding.bottomNavigation.show(itemId, true);
    }

    // Método para adicionar badge de notificação
    public void setNotificationBadge(String count) {
        binding.bottomNavigation.setCount(ID_NOTIF, count);
    }

    // Método para limpar badge de notificação
    public void clearNotificationBadge() {
        binding.bottomNavigation.clearCount(ID_NOTIF);
    }

    // Método para limpar todos os badges
    public void clearAllBadges() {
        binding.bottomNavigation.clearAllCounts();
    }

    // Getter para o item atualmente selecionado
    public int getCurrentSelectedItem() {
        return currentSelectedId;
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        binding = null; // Previne memory leaks
    }
}