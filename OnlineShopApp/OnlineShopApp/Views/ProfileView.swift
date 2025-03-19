//
//  ProfileView.swift
//  OnlineShopApp
//
//  Created by Philipp Hermann on 19.12.24.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @ObservedObject var favoritesViewModel: FavoritesViewModel
    @ObservedObject var cartViewModel: CartViewModel
    @State private var showImagePicker = false
    @State private var profileImage: UIImage?
    @State private var showSettings = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Profile Header
            VStack(spacing: 8) {
                // Profile Image
                ZStack(alignment: .bottomTrailing) {
                    if let image = profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 3))
                            .shadow(radius: 5)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.gray)
                    }
                    
                    Button(action: { showImagePicker = true }) {
                        Image(systemName: "camera.circle.fill")
                            .font(.system(size: 35))
                            .foregroundColor(.black)
                            .background(Circle().fill(.white))
                    }
                }
                .padding(.top, 12)
                
                // User Info
                VStack(spacing: 4) {
                    if let user = authViewModel.currentUser {
                        Text(user.fullName)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    
                    if let email = Auth.auth().currentUser?.email {
                        Text(email)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.top, 8)
            }
            
            // Stats
            HStack(spacing: 40) {
                VStack {
                    Text("\(cartViewModel.orderHistory.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Bestellungen")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                VStack {
                    Text("\(favoritesViewModel.favoriteItems.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Wunschliste")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                VStack {
                    Text("\(cartViewModel.reviews.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Reviews")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 8)
            
            // Settings List
            List {
                Section("Einstellungen") {
                    Button(action: { showSettings = true }) {
                        SettingsRow(icon: "bell.fill", title: "Benachrichtigungen")
                    }
                    
                    Button(action: {}) {
                        SettingsRow(icon: "lock.fill", title: "Privatsphäre")
                    }
                    
                    Button(action: {}) {
                        SettingsRow(icon: "questionmark.circle.fill", title: "Hilfe")
                    }
                }
                
                Section("Account") {
                    NavigationLink(destination: OrderHistoryView(cartViewModel: cartViewModel)) {
                        SettingsRow(icon: "bag.fill", title: "Meine Bestellungen")
                    }
                    
                    NavigationLink(destination: FavoritesView(favoritesViewModel: favoritesViewModel, cartViewModel: cartViewModel)) {
                        SettingsRow(icon: "heart.fill", title: "Wunschliste")
                    }
                }
                
                Section {
                    Button(action: { authViewModel.signOut() }) {
                        SettingsRow(icon: "arrow.right.circle.fill", title: "Ausloggen")
                            .foregroundColor(.red)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $profileImage)
        }
        .sheet(isPresented: $showSettings) {
            NotificationSettingsView()
        }
    }
}

// Helper Views
struct SettingsRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .frame(width: 24, height: 24)
            Text(title)
        }
    }
}

struct NotificationSettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Toggle("Push-Benachrichtigungen", isOn: .constant(true))
                Toggle("E-Mail-Benachrichtigungen", isOn: .constant(true))
                Toggle("Angebote & Rabatte", isOn: .constant(true))
                Toggle("Bestellstatus", isOn: .constant(true))
            }
            .navigationTitle("Benachrichtigungen")
            .navigationBarItems(trailing: Button("Fertig") { dismiss() })
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
    }
}

// Neue View für Bestellhistorie
struct OrderHistoryView: View {
    @ObservedObject var cartViewModel: CartViewModel
    
    var body: some View {
        List(cartViewModel.orderHistory) { order in
            VStack(alignment: .leading, spacing: 8) {
                Text("Bestellung #\(order.id)")
                    .font(.headline)
                Text("Datum: \(order.date.formatted())")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Status: \(order.status)")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                Text("Gesamt: $\(String(format: "%.2f", order.total))")
                    .fontWeight(.semibold)
            }
            .padding(.vertical, 8)
        }
        .navigationTitle("Meine Bestellungen")
    }
}

// Neue Model für Bestellungen
struct Order: Identifiable {
    let id: String
    let date: Date
    let items: [CartItem]
    let total: Double
    let status: String
}

#Preview {
    ProfileView(
        favoritesViewModel: FavoritesViewModel(),
        cartViewModel: CartViewModel()
    )
}
