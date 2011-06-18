var apiBase = "http://localhost:4000";  // XXX

function fetchPath(authorName) {
  $.ajax({
    url: apiBase + "/path/" + authorName + "/wycats",
    dataType: "json",

    statusCode: {
      200: function(data) { pathCallback(data, authorName) },
      404: notFoundCallback,
      500: error500Callback,
    }
  });
}

function error500Callback(data) {
  copy = $("#templates .error_500").clone();
  copy.find(".error_description").
    text("Error 500.");
  $("#path_results").empty().append(copy);
}

function notFoundCallback(response) {
  data = JSON.parse(response.responseText);
  console.log(data);
  var author_names = data["unknown-authors"].join(" or ");

  copy = $("#templates .unknown_authors").clone();
  copy.find(".unknown_author_names").
    text(author_names);

  $("#path_results").empty();
  $("#path_results").append(copy);
}

function projectLink(project) {
  return $("<a></a>").
    addClass("project").
    attr("href", "https://github.com/" + project.name).
    text(project.name);
}

function collaboration(author1, project, author2) {
}

function displayPathComponent(author1, project, author2) {
  $("#path_results").
    append($("<p></p>").
           addClass("result_row").
           append(util.userWithGravatar(author1).
                  addClass("left")).
           append($("<span></span>").
                  addClass("project").
                  append("worked on ").
                  append(projectLink(project)).
                  append(" with")).
           append(util.userWithGravatar(author2).
                  addClass("right")));
}

function pathCallback(data, authorName) {
  $("#path_results").empty();
  for (var i = 0; i < (data.length - 2); i = i + 2) {
    displayPathComponent(data[i], data[i+1], data[i+2])
  }
}

$(document).ready(function() {
  $("#path_form").submit(function(event) {
    fetchPath($("#username").val().trim());
    return false;
  });
});
