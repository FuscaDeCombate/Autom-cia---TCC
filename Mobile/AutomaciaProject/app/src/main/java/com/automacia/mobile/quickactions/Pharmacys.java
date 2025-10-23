package com.automacia.mobile.quickactions;

import android.Manifest;
import android.content.pm.PackageManager;
import android.location.Location;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.activity.EdgeToEdge;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import androidx.swiperefreshlayout.widget.SwipeRefreshLayout;

import com.automacia.mobile.R;
import com.automacia.mobile.adapters.PharmacyAdapter;
import com.automacia.mobile.models.PharmacyDTO;
import com.google.android.material.bottomsheet.BottomSheetBehavior;
import com.google.android.material.chip.Chip;
import com.google.android.material.floatingactionbutton.FloatingActionButton;

import org.json.JSONArray;
import org.json.JSONObject;
import org.osmdroid.api.IMapController;
import org.osmdroid.config.Configuration;
import org.osmdroid.tileprovider.tilesource.TileSourceFactory;
import org.osmdroid.util.GeoPoint;
import org.osmdroid.views.CustomZoomButtonsController;
import org.osmdroid.views.MapView;
import org.osmdroid.views.overlay.Marker;
import org.osmdroid.views.overlay.mylocation.GpsMyLocationProvider;
import org.osmdroid.views.overlay.mylocation.MyLocationNewOverlay;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class Pharmacys extends AppCompatActivity {

    private static final String TAG = "PharmacysActivity";
    private static final int LOCATION_PERMISSION_REQUEST = 1;
    private static final int SEARCH_RADIUS_KM = 5;

    // Views
    private MapView mapView;
    private RecyclerView pharmacyRecyclerView;
    private PharmacyAdapter pharmacyAdapter;
    private TextView resultCountText;
    private EditText searchEditText;
    private ImageView filterButton;
    private Chip chip24h, chipOpen, chipNearby;
    private FloatingActionButton myLocationButton, zoomInButton, zoomOutButton;
    private FrameLayout loadingOverlay;
    private BottomSheetBehavior<View> bottomSheetBehavior;
    private SwipeRefreshLayout swipeRefresh;

    // Map
    private MyLocationNewOverlay myLocationOverlay;
    private IMapController mapController;
    private GeoPoint userLocation;

    // Data
    private List<PharmacyDTO> allPharmacies = new ArrayList<>();
    private List<PharmacyDTO> filteredPharmacies = new ArrayList<>();
    private List<Marker> pharmacyMarkers = new ArrayList<>();

    // Filters
    private boolean filter24h = false;
    private boolean filterOpen = false;
    private boolean filterNearby = false;

    // ExecutorService para requisições assíncronas
    private ExecutorService executorService;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_pharmacys);
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        executorService = Executors.newSingleThreadExecutor();

        initializeOSMConfig();
        initViews();
        setupMap();
        setupSwipeRefresh();
        setupRecyclerView();
        setupBottomSheet();
        setupListeners();
        checkLocationPermission();
    }

    private void initializeOSMConfig() {
        Configuration.getInstance().setUserAgentValue(getPackageName());
        Configuration.getInstance().load(this, getPreferences(MODE_PRIVATE));
    }

    private void initViews() {
        mapView = findViewById(R.id.mapView);
        pharmacyRecyclerView = findViewById(R.id.pharmacyRecyclerView);
        resultCountText = findViewById(R.id.resultCountText);
        searchEditText = findViewById(R.id.searchEditText);
        filterButton = findViewById(R.id.filterButton);
        chip24h = findViewById(R.id.chip24h);
        chipOpen = findViewById(R.id.chipOpen);
        chipNearby = findViewById(R.id.chipNearby);
        myLocationButton = findViewById(R.id.myLocationButton);
        zoomInButton = findViewById(R.id.zoomInButton);
        zoomOutButton = findViewById(R.id.zoomOutButton);
        loadingOverlay = findViewById(R.id.loadingOverlay);
    }

    private void setupMap() {
        mapView.setTileSource(TileSourceFactory.MAPNIK);
        mapView.setMultiTouchControls(true);
        mapView.setBuiltInZoomControls(false);

        mapController = mapView.getController();
        mapController.setZoom(15.0);

        // Localização padrão (São Paulo)
        GeoPoint startPoint = new GeoPoint(-23.5505, -46.6333);
        mapController.setCenter(startPoint);

        // Overlay de localização
        myLocationOverlay = new MyLocationNewOverlay(new GpsMyLocationProvider(this), mapView);
        myLocationOverlay.enableMyLocation();
        mapView.getOverlays().add(myLocationOverlay);
    }

    private void setupSwipeRefresh() {
        swipeRefresh = findViewById(R.id.swipeRefresh);
        swipeRefresh.setOnRefreshListener(() -> {
            if (userLocation != null) {
                fetchPharmaciesFromOSM(
                        userLocation.getLatitude(),
                        userLocation.getLongitude()
                );
            }
            swipeRefresh.setRefreshing(false);
        });
    }

    private void setupRecyclerView() {
        pharmacyRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        pharmacyRecyclerView.setHasFixedSize(true);

        pharmacyAdapter = new PharmacyAdapter(this, new PharmacyAdapter.OnPharmacyClickListener() {
            @Override
            public void onPharmacyClick(PharmacyDTO pharmacy) {
                centerMapOnPharmacy(pharmacy);
                highlightMarker(pharmacy);
            }

            @Override
            public void onRouteClick(PharmacyDTO pharmacy) {
                // Já implementado no adapter
            }

            @Override
            public void onCallClick(PharmacyDTO pharmacy) {
                // Já implementado no adapter
            }

            @Override
            public void onDetailsClick(PharmacyDTO pharmacy) {
                showPharmacyDetails(pharmacy);
            }
        });

        pharmacyRecyclerView.setAdapter(pharmacyAdapter);
    }

    private void setupBottomSheet() {
        View bottomSheet = findViewById(R.id.bottomSheet);
        bottomSheetBehavior = BottomSheetBehavior.from(bottomSheet);
        bottomSheetBehavior.setPeekHeight(350);
        bottomSheetBehavior.setState(BottomSheetBehavior.STATE_COLLAPSED);
    }

    private void setupListeners() {
        // Botão minha localização
        myLocationButton.setOnClickListener(v -> {
            if (myLocationOverlay.getMyLocation() != null) {
                GeoPoint myLocation = myLocationOverlay.getMyLocation();
                mapController.animateTo(myLocation);
                userLocation = myLocation;
                fetchPharmaciesFromOSM(myLocation.getLatitude(), myLocation.getLongitude());
            } else {
                Toast.makeText(this, "Obtendo localização...", Toast.LENGTH_SHORT).show();
            }
        });

        // Botões de zoom
        zoomInButton.setOnClickListener(v -> mapController.zoomIn());
        zoomOutButton.setOnClickListener(v -> mapController.zoomOut());

        // Busca
        searchEditText.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {}

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                filterPharmacies(s.toString());
            }

            @Override
            public void afterTextChanged(Editable s) {}
        });

        // Chips de filtro
        chip24h.setOnClickListener(v -> {
            filter24h = chip24h.isChecked();
            applyFilters();
        });

        chipOpen.setOnClickListener(v -> {
            filterOpen = chipOpen.isChecked();
            applyFilters();
        });

        chipNearby.setOnClickListener(v -> {
            filterNearby = chipNearby.isChecked();
            applyFilters();
        });
    }

    private void checkLocationPermission() {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION)
                != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this,
                    new String[]{Manifest.permission.ACCESS_FINE_LOCATION},
                    LOCATION_PERMISSION_REQUEST);
        } else {
            getUserLocationAndFetchPharmacies();
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions,
                                           @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == LOCATION_PERMISSION_REQUEST) {
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                getUserLocationAndFetchPharmacies();
            } else {
                Toast.makeText(this, "Permissão de localização negada", Toast.LENGTH_SHORT).show();
                // Usa localização padrão
                fetchPharmaciesFromOSM(-23.5505, -46.6333);
            }
        }
    }

    private void getUserLocationAndFetchPharmacies() {
        myLocationOverlay.runOnFirstFix(() -> {
            Location location = myLocationOverlay.getLastFix();
            if (location != null) {
                runOnUiThread(() -> {
                    userLocation = new GeoPoint(location.getLatitude(), location.getLongitude());
                    mapController.animateTo(userLocation);
                    fetchPharmaciesFromOSM(location.getLatitude(), location.getLongitude());
                });
            }
        });
    }

    private void fetchPharmaciesFromOSM(double latitude, double longitude) {
        showLoading(true);

        executorService.execute(() -> {
            try {
                // Query Overpass API
                String query = buildOverpassQuery(latitude, longitude, SEARCH_RADIUS_KM);
                String response = makeOverpassRequest(query);
                List<PharmacyDTO> pharmacies = parseOverpassResponse(response, latitude, longitude);

                runOnUiThread(() -> {
                    allPharmacies = pharmacies;
                    applyFilters();
                    addMarkersToMap(pharmacies);
                    showLoading(false);
                });

            } catch (Exception e) {
                Log.e(TAG, "Erro ao buscar farmácias", e);
                runOnUiThread(() -> {
                    showLoading(false);
                    Toast.makeText(this, "Erro ao buscar farmácias: " + e.getMessage(),
                            Toast.LENGTH_SHORT).show();
                });
            }
        });
    }

    private String buildOverpassQuery(double lat, double lon, int radiusKm) {
        int radiusMeters = radiusKm * 1000;
        return String.format(
                "[out:json][timeout:25];" +
                        "(" +
                        "  node[\"amenity\"=\"pharmacy\"](around:%d,%f,%f);" +
                        "  way[\"amenity\"=\"pharmacy\"](around:%d,%f,%f);" +
                        ");" +
                        "out body;" +
                        ">;out skel qt;",
                radiusMeters, lat, lon, radiusMeters, lat, lon
        );
    }

    private String makeOverpassRequest(String query) throws Exception {
        String urlString = "https://overpass-api.de/api/interpreter";
        URL url = new URL(urlString);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setDoOutput(true);
        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded; charset=UTF-8");
        conn.setRequestProperty("Accept", "application/json");
        conn.setConnectTimeout(15000);
        conn.setReadTimeout(30000);

        String encodedQuery = "data=" + URLEncoder.encode(query, "UTF-8");

        try (OutputStream os = conn.getOutputStream()) {
            os.write(encodedQuery.getBytes(StandardCharsets.UTF_8));
            os.flush();
        }

        int status = conn.getResponseCode();
        InputStream inputStream = (status >= 200 && status < 300)
                ? conn.getInputStream()
                : conn.getErrorStream();

        StringBuilder response = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(inputStream, StandardCharsets.UTF_8))) {
            String line;
            while ((line = reader.readLine()) != null) {
                response.append(line);
            }
        }

        return response.toString();
    }

    private List<PharmacyDTO> parseOverpassResponse(String jsonResponse, double userLat, double userLon) {
        List<PharmacyDTO> pharmacies = new ArrayList<>();

        try {
            JSONObject root = new JSONObject(jsonResponse);
            JSONArray elements = root.getJSONArray("elements");

            for (int i = 0; i < elements.length(); i++) {
                JSONObject element = elements.getJSONObject(i);

                if (element.has("tags")) {
                    JSONObject tags = element.getJSONObject("tags");

                    double lat = element.optDouble("lat", 0);
                    double lon = element.optDouble("lon", 0);

                    if (lat == 0 || lon == 0) continue;

                    String name = tags.optString("name", "Farmácia");
                    String addr = buildAddress(tags);
                    String phone = tags.optString("phone", tags.optString("contact:phone", ""));
                    String openingHours = tags.optString("opening_hours", "");

                    PharmacyDTO pharmacy = new PharmacyDTO(
                            String.valueOf(element.optLong("id")),
                            name,
                            addr,
                            lat,
                            lon,
                            phone
                    );

                    pharmacy.setDistanceInKm(calculateDistance(userLat, userLon, lat, lon));
                    pharmacy.setOpeningHours(openingHours);
                    pharmacy.set24Hours(is24Hours(openingHours));
                    pharmacy.setOpen(isCurrentlyOpen(openingHours));
                    pharmacy.setClosingTime(getClosingTime(openingHours));

                    pharmacies.add(pharmacy);
                }
            }

            // Ordena por distância
            pharmacies.sort((p1, p2) -> Double.compare(p1.getDistanceInKm(), p2.getDistanceInKm()));

        } catch (Exception e) {
            Log.e(TAG, "Erro ao parsear resposta", e);
        }

        return pharmacies;
    }

    private String buildAddress(JSONObject tags) {
        StringBuilder addr = new StringBuilder();
        String street = tags.optString("addr:street", "");
        String number = tags.optString("addr:housenumber", "");
        String district = tags.optString("addr:suburb", tags.optString("addr:neighbourhood", ""));

        if (!street.isEmpty()) {
            addr.append(street);
            if (!number.isEmpty()) {
                addr.append(", ").append(number);
            }
        }
        if (!district.isEmpty()) {
            if (addr.length() > 0) addr.append(" - ");
            addr.append(district);
        }

        return addr.length() > 0 ? addr.toString() : "Endereço não disponível";
    }

    private double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        final int R = 6371; // Raio da Terra em km
        double latDistance = Math.toRadians(lat2 - lat1);
        double lonDistance = Math.toRadians(lon2 - lon1);
        double a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(lonDistance / 2) * Math.sin(lonDistance / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }

    private boolean is24Hours(String openingHours) {
        return openingHours.contains("24/7") || openingHours.contains("00:00-24:00");
    }

    private boolean isCurrentlyOpen(String openingHours) {
        if (openingHours == null || openingHours.isEmpty()) return false;
        if (is24Hours(openingHours)) return true;

        try {
            Calendar now = Calendar.getInstance();
            int currentDay = now.get(Calendar.DAY_OF_WEEK);
            int currentHour = now.get(Calendar.HOUR_OF_DAY);
            int currentMinute = now.get(Calendar.MINUTE);

            // Exemplo de parsing para formato "Mo-Fr 08:00-20:00; Sa 09:00-18:00"
            String[] periods = openingHours.split(";");

            for (String period : periods) {
                period = period.trim();

                // Parse dias da semana
                String[] parts = period.split(" ");
                if (parts.length < 2) continue;

                String days = parts[0];
                String hours = parts[1];

                // Verifica se hoje está no range de dias
                if (isDayInRange(currentDay, days)) {
                    // Parse horários
                    if (hours.contains("-")) {
                        String[] timeParts = hours.split("-");
                        if (timeParts.length == 2) {
                            int openHour = parseTime(timeParts[0]);
                            int closeHour = parseTime(timeParts[1]);
                            int currentTimeInMinutes = currentHour * 60 + currentMinute;

                            if (currentTimeInMinutes >= openHour && currentTimeInMinutes < closeHour) {
                                return true;
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            Log.e(TAG, "Erro ao parsear horário", e);
        }

        // Fallback para horário comercial
        Calendar now = Calendar.getInstance();
        int hour = now.get(Calendar.HOUR_OF_DAY);
        return hour >= 8 && hour < 22;
    }

    private int parseTime(String time) {
        try {
            String[] parts = time.split(":");
            int hours = Integer.parseInt(parts[0].trim());
            int minutes = parts.length > 1 ? Integer.parseInt(parts[1].trim()) : 0;
            return hours * 60 + minutes;
        } catch (Exception e) {
            return 0;
        }
    }

    private boolean isDayInRange(int currentDay, String dayRange) {
        // Converter Calendar.DAY_OF_WEEK para formato OSM
        // Calendar: 1=Sunday, 2=Monday, ..., 7=Saturday
        // OSM: Mo, Tu, We, Th, Fr, Sa, Su

        String[] dayAbbrevs = {"Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"};
        String currentDayAbbrev = dayAbbrevs[currentDay - 1];

        // Verifica ranges como "Mo-Fr"
        if (dayRange.contains("-")) {
            String[] parts = dayRange.split("-");
            if (parts.length == 2) {
                int startDay = getDayNumber(parts[0].trim());
                int endDay = getDayNumber(parts[1].trim());
                int current = getDayNumber(currentDayAbbrev);

                if (startDay <= endDay) {
                    return current >= startDay && current <= endDay;
                } else {
                    // Range que passa pela semana (ex: Sa-Mo)
                    return current >= startDay || current <= endDay;
                }
            }
        }

        return dayRange.contains(currentDayAbbrev);
    }

    private int getDayNumber(String day) {
        String[] days = {"Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"};
        for (int i = 0; i < days.length; i++) {
            if (days[i].equals(day)) return i;
        }
        return -1;
    }

    private String getClosingTime(String openingHours) {
        if (openingHours.isEmpty() || is24Hours(openingHours)) return "";

        // Parse simples - melhorar conforme necessário
        if (openingHours.contains("-")) {
            String[] parts = openingHours.split("-");
            if (parts.length > 1) {
                return parts[1].trim();
            }
        }
        return "22:00";
    }

    private void addMarkersToMap(List<PharmacyDTO> pharmacies) {
        // Remove marcadores antigos
        for (Marker marker : pharmacyMarkers) {
            mapView.getOverlays().remove(marker);
        }
        pharmacyMarkers.clear();

        // Adiciona novos marcadores
        for (PharmacyDTO pharmacy : pharmacies) {
            Marker marker = new Marker(mapView);
            marker.setPosition(new GeoPoint(pharmacy.getLatitude(), pharmacy.getLongitude()));
            marker.setAnchor(Marker.ANCHOR_CENTER, Marker.ANCHOR_BOTTOM);
            marker.setTitle(pharmacy.getName());
            marker.setSnippet(pharmacy.getAddress());

            marker.setOnMarkerClickListener((m, mapView) -> {
                centerMapOnPharmacy(pharmacy);
                // Scroll RecyclerView para a farmácia
                int position = filteredPharmacies.indexOf(pharmacy);
                if (position >= 0) {
                    pharmacyRecyclerView.smoothScrollToPosition(position);
                }
                return true;
            });

            mapView.getOverlays().add(marker);
            pharmacyMarkers.add(marker);
        }

        mapView.invalidate();
    }

    private void centerMapOnPharmacy(PharmacyDTO pharmacy) {
        GeoPoint point = new GeoPoint(pharmacy.getLatitude(), pharmacy.getLongitude());
        mapController.animateTo(point);
        mapController.setZoom(17.0);
    }

    private void highlightMarker(PharmacyDTO pharmacy) {
        // Encontra e destaca o marcador correspondente
        for (Marker marker : pharmacyMarkers) {
            if (marker.getPosition().getLatitude() == pharmacy.getLatitude() &&
                    marker.getPosition().getLongitude() == pharmacy.getLongitude()) {
                marker.showInfoWindow();
                break;
            }
        }
    }

    private void filterPharmacies(String searchText) {
        filteredPharmacies.clear();

        for (PharmacyDTO pharmacy : allPharmacies) {
            if (pharmacy.getName().toLowerCase().contains(searchText.toLowerCase()) ||
                    pharmacy.getAddress().toLowerCase().contains(searchText.toLowerCase())) {
                filteredPharmacies.add(pharmacy);
            }
        }

        pharmacyAdapter.setPharmacies(filteredPharmacies);
        updateResultCount();
    }

    private void applyFilters() {
        filteredPharmacies.clear();

        for (PharmacyDTO pharmacy : allPharmacies) {
            boolean matches = true;

            if (filter24h && !pharmacy.is24Hours()) {
                matches = false;
            }

            if (filterOpen && !pharmacy.isOpen()) {
                matches = false;
            }

            if (filterNearby && pharmacy.getDistanceInKm() > 2.0) {
                matches = false;
            }

            if (matches) {
                filteredPharmacies.add(pharmacy);
            }
        }

        pharmacyAdapter.setPharmacies(filteredPharmacies);
        updateResultCount();
    }

    private void updateResultCount() {
        int count = filteredPharmacies.size();
        String text = count + " farmácia" + (count != 1 ? "s" : "") + " encontrada" + (count != 1 ? "s" : "");
        resultCountText.setText(text);
    }

    private void showPharmacyDetails(PharmacyDTO pharmacy) {
        Toast.makeText(this, "Detalhes de: " + pharmacy.getName(), Toast.LENGTH_SHORT).show();
        // TODO: Implementar tela de detalhes
    }

    private void showLoading(boolean show) {
        loadingOverlay.setVisibility(show ? View.VISIBLE : View.GONE);
        if (!show) {
            resultCountText.setText("Buscando farmácias...");
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        mapView.onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
        mapView.onPause();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (executorService != null) {
            executorService.shutdown();
        }
    }
}