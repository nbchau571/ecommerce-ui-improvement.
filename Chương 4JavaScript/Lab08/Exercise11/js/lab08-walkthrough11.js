var countries = [
    { name: "Canada", iso: "CA" },
    { name: "Germany", iso: "DE" },
    { name: "Spain", iso: "ES" },
    { name: "United Kingdom", iso: "GB" },
    { name: "United States", iso: "US" }
];
for (var i = 0; i < countries.length; i++) {
    var c = countries[i];
    document.write("<div class='box'>");
    document.write("<img src='flags/" + c.iso + ".png' class='boxImg'>");

    for (var propertyName in c) {
        document.write("<strong>");
        document.write(propertyName + ": ");
        document.write("</strong>");

        document.write(c[propertyName]);
        document.write("<br>");
    }
    document.write("</div>");
}

