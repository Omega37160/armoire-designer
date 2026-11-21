fn main() {
    println!("cargo:rerun-if-changed=assets/ArmoireDesigner.html");
    println!("cargo:rerun-if-changed=assets/ArmoireDesigner.ico");
    println!("cargo:rerun-if-env-changed=ARMOIRE_UPDATE_URL");
    println!("cargo:rerun-if-env-changed=ARMOIRE_PORTABLE");
    if std::env::var("CARGO_CFG_TARGET_OS").as_deref() == Ok("windows") {
        let mut res = winresource::WindowsResource::new();
        if std::path::Path::new("assets/ArmoireDesigner.ico").exists() {
            res.set_icon("assets/ArmoireDesigner.ico");
        }
        res.set("ProductName", "Armoire Designer");
        res.set("FileDescription", "Armoire Designer");
        res.compile().expect("ressources Windows");
    }
}
