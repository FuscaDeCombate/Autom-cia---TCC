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

public class MainActivity extends AppCompatActivity {

    private ActivityMainBinding binding;
    private FragmentManager fragmentManager;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);

        binding = ActivityMainBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        fragmentManager = getSupportFragmentManager();

        setupWindowInsets();
        setupViews();
        setupBottomNavigation();

        // Carrega fragment inicial apenas se não houver estado salvo
        if (savedInstanceState == null) {
            replaceFragment(new HomeFragment());
        }
    }

    private void setupWindowInsets() {
        ViewCompat.setOnApplyWindowInsetsListener(binding.main, (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });
    }

    private void setupViews() {
        binding.fab.setOnClickListener(v -> {
            replaceFragment(new HomeFragment());
            // Sincroniza com bottom navigation se necessário
            // binding.bottomNavigationBar.setSelectedItemId(R.id.mnHome);
        });

        binding.bottomNavigationBar.setBackground(null);
    }

    private void setupBottomNavigation() {
        binding.bottomNavigationBar.setOnItemSelectedListener(item -> {
            int itemId = item.getItemId();
            Fragment selectedFragment = null;

            if (itemId == R.id.mnChat) {
                selectedFragment = new ChatFragment();
            } else if (itemId == R.id.mnNotif) {
                selectedFragment = new NotificationFragment();
            } else if (itemId == R.id.mnPref) {
                selectedFragment = new PreferencesFragment();
            } else if (itemId == R.id.mnUser) {
                selectedFragment = new UserFragment();
            }

            if (selectedFragment != null) {
                replaceFragment(selectedFragment);
                return true;
            }

            return false;
        });
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

    @Override
    protected void onDestroy() {
        super.onDestroy();
        binding = null; // Previne memory leaks
    }
}