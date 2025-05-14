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
            switch (item.getItemId()) {
                case R.id.mnHome:
                    replaceFragment(new HomeFragment());
                    break;
                case R.id.mnChat:
                    replaceFragment(new ChatFragment());
                    break;
                case R.id.mnPref:
                    replaceFragment(new PreferencesFragment());
                    break;
                case R.id.mnUser:
                    replaceFragment(new UserFragment());
                    break;
                case R.id.mnNotif:
                    replaceFragment(new NotificationFragment());
                    break;
                default:
                    throw new IllegalStateException("Unexpected value: " + item.getItemId());
            }
        });
    }

    private void replaceFragment(Fragment frag) {
        FragmentManager fragManager = getSupportFragmentManager();
        FragmentTransaction fragTransaction = fragManager.beginTransaction();
        fragTransaction.replace(R.id.flFragment, frag);
        fragTransaction.commit();
    }
}