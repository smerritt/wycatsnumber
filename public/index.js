var apiBase = "/api";

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

function displayAuthor(author) {
  copy = $("#templates .author_path_component").clone();

  copy.
    find("img.gravatar").
    attr("src", util.gravatar_url(author));

  copy.
    find("a.username").
    attr("href", util.author_url(author)).
    text(author.name);

  $("#path_results").append(copy);
}

function displayProject(project) {
  copy = $("#templates .project_path_component").clone();

  copy.
    find("a.project_link").
    attr("href", util.project_url(project)).
    text(project.name);

  $("#path_results").append(copy);
}

function pathCallback(data, authorName) {
  $("#path_results").empty();
  $.each(data, function(idx, elem) {
    if (elem.type == "author")
      displayAuthor(elem);
    else if (elem.type == "project")
      displayProject(elem);
  })
}

$(document).ready(function() {
  $("#path_form").submit(function(event) {
    fetchPath($("#username").val().trim());
    return false;
  });
});
