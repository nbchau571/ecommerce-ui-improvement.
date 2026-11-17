var daysOfWeek = new Array("Mon", "Tues", "Wed", "Thur", "Fri");
document.write(daysOfWeek + "<br>");

var daysOfWeek = new Array("Mon", "Tues", "Wed", "Thur", "Fri");
daysOfWeek.push("Sat");
document.write(daysOfWeek + "<br>");

var daysOfWeek = new Array("Mon", "Tues", "Wed", "Thur", "Fri");
daysOfWeek.push("Sat");
daysOfWeek.unshift("Sun");
document.write(daysOfWeek + "<br>");

document.write("<table border='1'>");
document.write("<tr>");

document.write("<table border='1'>");
document.write("<tr>");

for (var i = 0; i < daysOfWeek.length; i++) {
    var day;

    if (daysOfWeek[i].length < 4) {
        day = daysOfWeek[i];
    } else {
        day = "<em>" + daysOfWeek[i] + "</em>";
    }

    document.write("<th>" + day + "</th>");
}

document.write("</tr>");
document.write("</table>");

var daysOfWeek = new Array("Mon", "Tues", "Wed", "Thur", "Fri");

// Add Saturday to the end
daysOfWeek.push("Sat");

// Add Sunday to the beginning
daysOfWeek.unshift("Sun");

// Create calendar table
document.write("<table border='1'>");
document.write("<tr>");

// Display days 1 to 30, starting on Sunday
var date = 1;

while (date <= 30) {
    document.write("<tr>");

    for (var j = 0; j < 7; j++) {
        if (date <= 30) {
            document.write("<td>" + date + "</td>");
            date++;
        } else {
            document.write("<td></td>");
        }
    }

    document.write("</tr>");
}

document.write("</table>");
