// Armoire Designer — application de bureau (Rust + WebView2) avec installation
// et mises à jour automatiques par Velopack.
#![windows_subsystem = "windows"]

use std::{
    fs,
    path::{Path, PathBuf},
    thread,
};
use tao::{
    event::{Event, WindowEvent},
    event_loop::{ControlFlow, EventLoop},
    window::WindowBuilder,
};
use wry::{WebContext, WebViewBuilder};

/// L'application web complète est intégrée dans l'exécutable.
const APP_HTML: &str = include_str!("../assets/ArmoireDesigner.html");
/// Adresse du dossier de mises à jour (sortie de `vpk pack`), fixée à la compilation :
///   set ARMOIRE_UPDATE_URL=https://mon-serveur/armoire/releases
const UPDATE_URL: Option<&str> = option_env!("ARMOIRE_UPDATE_URL");
/// Version portable : pas d'installation, pas de mises à jour, données à côté de l'exe.
const PORTABLE: bool = option_env!("ARMOIRE_PORTABLE").is_some();

/// Données utilisateur (stockage local de la WebView, copie de l'interface).
/// Volontairement hors de %LOCALAPPDATA%\ArmoireDesigner : Velopack y installe
/// l'application et supprime ce dossier à la désinstallation.
fn data_dir() -> PathBuf {
    // Version portable (compilée avec ARMOIRE_PORTABLE=1) : données à côté de l'exe,
    // sauf si ce dossier n'est pas accessible en écriture.
    if PORTABLE {
        if let Some(d) = std::env::current_exe()
            .ok()
            .and_then(|e| e.parent().map(|p| p.join("ArmoireDesigner-donnees")))
        {
            if fs::create_dir_all(&d).is_ok() && fs::write(d.join(".test"), b"").is_ok() {
                let _ = fs::remove_file(d.join(".test"));
                return d;
            }
        }
    }
    let base = std::env::var_os("APPDATA")
        .or_else(|| std::env::var_os("LOCALAPPDATA"))
        .map(PathBuf::from)
        .unwrap_or_else(std::env::temp_dir);
    base.join("Armoire Designer")
}

/// Chemin Windows -> URL file:/// (encode espaces, accents et autres caractères non sûrs).
fn file_url(p: &Path) -> String {
    let mut u = String::from("file:///");
    for b in p.display().to_string().replace('\\', "/").bytes() {
        match b {
            b'A'..=b'Z' | b'a'..=b'z' | b'0'..=b'9' | b'/' | b':' | b'-' | b'_' | b'.' | b'~' => {
                u.push(b as char)
            }
            _ => u.push_str(&format!("%{b:02X}")),
        }
    }
    u
}

fn check_updates(url: String) {
    use velopack::{sources::HttpSource, UpdateCheck, UpdateManager};
    let Ok(um) = UpdateManager::new(HttpSource::new(&url), None, None) else {
        return; // application lancée hors installation (développement)
    };
    if let Ok(UpdateCheck::UpdateAvailable(updates)) = um.check_for_updates() {
        let v = updates.TargetFullRelease.Version.clone();
        let ok = rfd::MessageDialog::new()
            .set_title("Armoire Designer")
            .set_description(format!(
                "La version {v} est disponible.\nL'installer maintenant ? L'application redémarrera."
            ))
            .set_buttons(rfd::MessageButtons::YesNo)
            .show();
        if ok == rfd::MessageDialogResult::Yes && um.download_updates(&updates, None).is_ok() {
            let _ = um.apply_updates_and_restart(&*updates);
        }
    }
}

fn main() -> wry::Result<()> {
    // Doit être appelé en premier : gère les étapes d'installation / désinstallation Velopack.
    velopack::VelopackApp::build().run();

    // L'interface est écrite dans un dossier fixe : le stockage local (projets
    // sauvegardés automatiquement, bibliothèque, prix) reste le même d'une version à l'autre.
    let dir = data_dir();
    let app_dir = dir.join("app");
    fs::create_dir_all(&app_dir).ok();
    let page = app_dir.join("ArmoireDesigner.html");
    fs::write(&page, APP_HTML).expect("écriture de l'interface");
    let url = file_url(&page);

    if let Some(u) = UPDATE_URL.filter(|u| !u.is_empty() && !PORTABLE) {
        let u = u.to_string();
        thread::spawn(move || check_updates(u));
    }

    let event_loop = EventLoop::new();
    let window = WindowBuilder::new()
        .with_title("Armoire Designer")
        .with_maximized(true) // fenêtré, adapté à la taille de l'écran
        .build(&event_loop)
        .expect("création de la fenêtre");

    let mut ctx = WebContext::new(Some(dir.join("webview")));
    let _webview = WebViewBuilder::with_web_context(&mut ctx)
        .with_url(&url)
        // Exports (DXF, CSV, HTML, projet…) : on demande où enregistrer.
        .with_download_started_handler(|uri: String, path: &mut PathBuf| {
            let name = path
                .file_name()
                .map(|n| n.to_string_lossy().to_string())
                .unwrap_or_else(|| uri.rsplit('/').next().unwrap_or("export").to_string());
            match rfd::FileDialog::new().set_file_name(&name).save_file() {
                Some(p) => {
                    *path = p;
                    true
                }
                None => false,
            }
        })
        .build(&window)?;

    event_loop.run(move |event, _, control_flow| {
        *control_flow = ControlFlow::Wait;
        if let Event::WindowEvent { event: WindowEvent::CloseRequested, .. } = event {
            *control_flow = ControlFlow::Exit;
        }
    });
}
