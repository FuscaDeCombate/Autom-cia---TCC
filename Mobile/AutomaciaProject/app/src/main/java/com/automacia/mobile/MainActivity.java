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

    ActivityMainBinding binding;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        binding = ActivityMainBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars. left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        replaceFragment(new HomeFragment());
        binding.bottomNavigationBar.setBackground(null);

        binding.bottomNavigationBar.setOnItemSelectedListener(item -> {
            int itemid = item.getItemId();

            if (itemid == R.id.mnHome) {
                replaceFragment(new HomeFragment());
            } else if (itemid == R.id.mnChat) {
                replaceFragment(new ChatFragment());
            } else if (itemid == R.id.mnNotif) {
                replaceFragment(new NotificationFragment());
            } else if (itemid == R.id.mnPref) {
                replaceFragment(new PreferencesFragment());
            } else if (itemid == R.id.mnUser) {
                replaceFragment(new UserFragment());
            }

            return true;
        });
    }

    private void replaceFragment(Fragment frag) {
        FragmentManager fragManager = getSupportFragmentManager();
        FragmentTransaction fragTransaction = fragManager.beginTransaction();
        fragTransaction.replace(R.id.flFragment, frag);
        fragTransaction.commit();
    }
}