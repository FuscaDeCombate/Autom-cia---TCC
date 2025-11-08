package com.automacia.mobile;

import android.content.Intent;
import android.graphics.Rect;
import android.os.Bundle;
import android.view.View;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;

import com.automacia.mobile.databinding.ActivityMainBinding;
import com.automacia.mobile.fragments.ChatFragment;
import com.automacia.mobile.fragments.HomeFragment;
import com.automacia.mobile.fragments.NotificationFragment;
import com.automacia.mobile.fragments.PreferencesFragment;
import com.automacia.mobile.fragments.UserFragment;
import com.automacia.mobile.models.FuncionarioChatDTO;
import com.automacia.mobile.models.UsuarioDTO;
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

    // Fragments cacheados para melhor performance
    private Fragment homeFragment;
    private Fragment chatFragment;
    private Fragment notifFragment;
    private Fragment prefFragment;
    private Fragment userFragment;

    // Fragment atualmente visível
    private Fragment activeFragment;

    // Dados do Usuario
    private UsuarioDTO usuario;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);

        binding = ActivityMainBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        fragmentManager = getSupportFragmentManager();

        setupWindowInsets();
        setupNafisBottomNavigation();
        setupUserDTO();
        setupKeyboardListener();

        // Carrega fragments iniciais apenas se não houver estado salvo
        if (savedInstanceState == null) {
            initFragments();
            binding.bottomNavigation.show(ID_HOME, true);
        }

        verificarNavegacaoChat(getIntent());
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        verificarNavegacaoChat(intent);
    }

    /**
     * Configura os window insets para suporte a Edge-to-Edge
     */
    private void setupWindowInsets() {
        ViewCompat.setOnApplyWindowInsetsListener(binding.main, (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });
    }

    /**
     * Configura a navegação inferior (bottom navigation)
     */
    private void setupNafisBottomNavigation() {
        // Adiciona os itens do menu à navegação
        binding.bottomNavigation.add(new NafisBottomNavigation.Model(ID_NOTIF, R.drawable.ic_notifications));
        binding.bottomNavigation.add(new NafisBottomNavigation.Model(ID_CHAT, R.drawable.ic_chat));
        binding.bottomNavigation.add(new NafisBottomNavigation.Model(ID_HOME, R.drawable.ic_home));
        binding.bottomNavigation.add(new NafisBottomNavigation.Model(ID_USER, R.drawable.ic_person));
        binding.bottomNavigation.add(new NafisBottomNavigation.Model(ID_PREF, R.drawable.ic_settings));

        // Listener para quando um item é clicado
        binding.bottomNavigation.setOnClickMenuListener(new Function1<NafisBottomNavigation.Model, Unit>() {
            @Override
            public Unit invoke(NafisBottomNavigation.Model model) {
                handleNavigationClick(model.getId());
                return null;
            }
        });

        // Listener para quando um item é mostrado (para logs/analytics)
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
                // Implementa ações para re-seleção (scroll to top, refresh, etc.)
                handleReselectAction(model.getId());
                return null;
            }
        });
    }

    /***
     * Inicializa os dados do usuario pelo objeto UsuarioDTO salvo no MyApp
     */
    private void setupUserDTO() {
        MyApp app = (MyApp) getApplicationContext();
        usuario = app.getUsuarioLogado();
    }

    /**
     * Inicializa todos os fragments e os adiciona ao FragmentManager
     * Usa estratégia show/hide para melhor performance
     */
    private void initFragments() {
        // Cria instâncias dos fragments
        homeFragment = HomeFragment.newInstance(usuario);
        chatFragment = ChatFragment.newInstance(usuario);
        notifFragment = new NotificationFragment();
        prefFragment = new PreferencesFragment();
        userFragment = UserFragment.newInstance(usuario);

        // Define o fragment inicial como ativo
        activeFragment = homeFragment;

        // Adiciona todos os fragments ao container e oculta todos exceto o inicial
        // Esta abordagem evita recriar fragments, melhorando a performance
        fragmentManager.beginTransaction()
                .add(R.id.flFragment, userFragment, "USER").hide(userFragment)
                .add(R.id.flFragment, prefFragment, "PREF").hide(prefFragment)
                .add(R.id.flFragment, notifFragment, "NOTIF").hide(notifFragment)
                .add(R.id.flFragment, chatFragment, "CHAT").hide(chatFragment)
                .add(R.id.flFragment, homeFragment, "HOME") // Home fica visível inicialmente
                .commit();
    }

    /**
     * Gerencia o clique nos itens de navegação
     * Usa show/hide ao invés de replace para melhor performance
     */
    private void handleNavigationClick(int itemId) {
        Fragment target = null;

        switch (itemId) {
            case ID_HOME:
                target = homeFragment;
                break;
            case ID_CHAT:
                target = chatFragment;
                break;
            case ID_NOTIF:
                target = notifFragment;
                // Limpa o badge quando visualizar notificações
                binding.bottomNavigation.clearCount(ID_NOTIF);
                break;
            case ID_PREF:
                target = prefFragment;
                break;
            case ID_USER:
                target = userFragment;
                break;
        }

        // Só executa a transição se o fragment alvo for diferente do atual
        if (target != null && target != activeFragment) {
            FragmentTransaction transaction = fragmentManager.beginTransaction();
            // Adiciona animação suave de transição
            transaction.setTransition(FragmentTransaction.TRANSIT_FRAGMENT_FADE);
            // Oculta o fragment atual e mostra o novo
            transaction.hide(activeFragment).show(target).commit();
            activeFragment = target;
        }
    }

    /**
     * Gerencia ações quando um item já selecionado é clicado novamente
     */
    private void handleReselectAction(int itemId) {
        // Implementa ações específicas para cada tab quando re-selecionada
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

    /**
     * Verifica se deve navegar para o ChatFragment
     */
    private void verificarNavegacaoChat(Intent intent) {
        if (intent == null) return;

        if (intent.getBooleanExtra("navegar_para_chat", false)) {
            FuncionarioChatDTO funcionario =
                    (FuncionarioChatDTO) intent.getSerializableExtra("funcionario");

            // Navegar para a aba do chat
            binding.bottomNavigation.show(ID_CHAT, true);

            // Força a troca real do fragment ativo
            handleNavigationClick(ID_CHAT);

            // Se há um funcionário específico, atualizar o ChatFragment
            if (funcionario != null && chatFragment instanceof ChatFragment) {
                ((ChatFragment) chatFragment).atualizarFuncionario(funcionario);
            }

            // Limpar flag da intent para não processar novamente
            intent.removeExtra("navegar_para_chat");
        }
    }

    /**
     * Detecta quando o teclado é mostrado/escondido e ajusta a visibilidade do bottom navigation
     */
    private void setupKeyboardListener() {
        binding.getRoot().getViewTreeObserver().addOnGlobalLayoutListener(() -> {
            Rect r = new Rect();
            binding.getRoot().getWindowVisibleDisplayFrame(r);

            int screenHeight = binding.getRoot().getRootView().getHeight();
            int keypadHeight = screenHeight - r.bottom;

            // Se a altura do teclado for maior que 15% da tela, considera que está aberto
            if (keypadHeight > screenHeight * 0.15) {
                // Teclado aberto - escond  e o bottom navigation
                binding.bottomNavigation.setVisibility(View.GONE);
            } else {
                // Teclado fechado - mostra o bottom navigation
                binding.bottomNavigation.setVisibility(View.VISIBLE);
            }
        });
    }

    /**
     * Metodo para adicionar badge de notificação
     */
    public void setNotificationBadge(String count) {
        binding.bottomNavigation.setCount(ID_NOTIF, count);
    }

    /**
     * Metodo para limpar badge de notificação
     */
    public void clearNotificationBadge() {
        binding.bottomNavigation.clearCount(ID_NOTIF);
    }

    /**
     * Metodo para limpar todos os badges
     */
    public void clearAllBadges() {
        binding.bottomNavigation.clearAllCounts();
    }

    /**
     * Getter para o item atualmente selecionado
     */
    public int getCurrentSelectedItem() {
        return currentSelectedId;
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        binding = null; // Previne memory leaks
    }
}