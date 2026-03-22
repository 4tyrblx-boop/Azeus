function openLink(type) {
    const links = {
        youtube: "https://youtube.com/",
        telegram: "https://t.me/",
        discord: "https://discord.com/"
    };

    window.open(links[type], "_blank");
}
