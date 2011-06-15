var apiBase = "http://localhost:4000";

function fetchPath(authorName) {
  $.ajax({
    url: apiBase + "/path/" + authorName + "/wycats",
    dataType: "jsonp",
    success: function(data) { pathCallback(data, authorName) }
  });
}

function notFoundCallback(data) {
  // writeme
}

function displayPathComponent(author1, project, author2) {
  $("#path_results").
    append($("<p></p>").
           addClass("collaboration").
           text(author1.name + " -> " + project.name + " -> " + author2.name));
}

function pathCallback(data, authorName) {
  $("#path_results").empty();
  for (var i = 0; i < (data.length - 2); i = i + 2) {
    displayPathComponent(data[i], data[i+1], data[i+2])
  }
}

$(document).ready(function() {
  $("#path_form").submit(function(event) {
    fetchPath($("#username").val());
    return false;
  });
});
