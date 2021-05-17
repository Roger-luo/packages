using TOML
using Configurations

the_julia_language = """
<a href="https://julialang.org">
    <img src="https://raw.githubusercontent.com/JuliaLang/julia-logo-graphics/master/images/julia.ico" width="16em" style="position:relative; top:-0.1em;">
    Julia Programming Language
</a>
"""

head = """
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <title>Roger's packages</title>

    <!-- bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta1/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-giJF6kkoqNQ00vy+HMDP7azOuL0xtbfIcaT9wjKHr8RbDVddVHyTfAAsrekwKmP1" crossorigin="anonymous">
    <link rel="stylesheet" href="assets/main.css">
    <link rel="shortcut icon" type="image/x-icon" href="/images/favicon.jpeg">
    <script src="https://kit.fontawesome.com/0d64c2ab8c.js"></script>
</head>
"""

intro = """
<div class="home">
    <a href="https://rogerluo.dev">rogerluo.dev</a>
</div>
<div class="intro">
    <p>
        this page is made for convenience when someone (including myself)
        <strong>wants to check the status of packages I created/maintain.</strong>
    </p>

    <p>
        Most of the packages are written in $the_julia_language.
    </p>

    <p>
        My <strong>Julia software projects</strong> are usually <strong>organized as many small
        packages</strong> so that people can easily use different components
        for other purpose.
    </p>

    <p>
        The <strong>documentation</strong> of each project are maintained
        as a curated page under the project package. You can also find the
        link to them below.
    </p>
</div>
"""

theme_script = """
<script>
    const htmlEl = document.getElementsByTagName('html')[0];
    function toggle_theme(theme) {
        htmlEl.dataset.theme = theme;
    }

    function is_night() {
        var today = new Date();
        var hour = today.getHours();

        if (hour > 18 || hour < 7) {
            return true;
        }
        return false
    }

    if (is_night()) {
        toggle_theme('dark');
    } else {
        toggle_theme('light');
    }
</script>
"""

@option struct Package
    name::String
    description::String
    doc::Bool = true # has doc
    codecov::Bool = true # has codecov
    gh_action::Bool = true # has github action
    user::String = "Roger-luo" # github user
end

@option struct Project
    name::String
    description::String
    user::Maybe{String} = nothing
    page::Maybe{String} = nothing
    packages::Maybe{Vector{Package}} = nothing
end

@option struct Info
    project::Vector{Project}
end

repo_link(user, name) = "https://github.com/$(user)/$(name).jl"
page_link(user, name) = "https://$(user).github.io/$(name).jl"

package_badges(pkg::Package) = package_badges(pkg.user, pkg.name, pkg.doc, pkg.gh_action, pkg.codecov)

function package_badges(user, name, doc::Bool, gh_action::Bool, codecov::Bool)
    repo = repo_link(user, name)
    page = page_link(user, name)
    stable_link = "$page/stable"
    dev_link = "$page/dev"
    gha_link = "$repo/actions"
    codecov_link = "https://codecov.io/gh/$(user)/$(name).jl"

    stable_img = "https://img.shields.io/badge/docs-stable-blue.svg"
    dev_img = "https://img.shields.io/badge/docs-dev-blue.svg"
    gha_img = "$repo/workflows/CI/badge.svg"
    codecov_img = "https://codecov.io/gh/$(user)/$(name).jl/branch/master/graph/badge.svg"

    badge(img, link, alt) = """
    <a href="$link">
        <img src="$img" alt="$alt"></img>
    </a>
    """

    return """
    $(doc ? badge(stable_img, stable_link, "doc-stable") : "")
    $(doc ? badge(dev_img, dev_link, "doc-dev") : "")
    $(gh_action ? badge(gha_img, gha_link, "github-action") : "")
    $(codecov ? badge(codecov_img, codecov_link, "codecov") : "")
    """
end

function html(pkg::Package)
    """
    <li>
        <div class="pkg">
            <div class="pkg-name">
                <a href="$(repo_link(pkg.user, pkg.name))">$(pkg.name)</a>
            </div>
            <div class="pkg-badges">$(package_badges(pkg))</div>
            <div class="pkg-desc">$(pkg.description)</div>
        </div>
    </li>
    """
end

function html(project::Project)
    name = "<h1>$(project.name)</h1>"
    description = """
    <div class="description">
        $(project.description)
    </div>
    """

    page = isnothing(project.page) ? "" : """
    <div class="project-page">
        <a href="https://$(project.page)">$(project.page)</a>
    </div>
    """

    if isnothing(project.packages)
        user = isnothing(project.user) ? "Roger-luo" : project.user
        """
        <div class="project">
            $name
            $page
            <div class="pkg-badges">
                $(package_badges(user, project.name, true, true, true))
            </div>
            $description
        </div>
        """
    else
        packages = join([html(each) for each in project.packages], "\n")
        """
        <div class="project">
            $name
            $page
            $description
            <ul>
                $packages
            </ul>
        </div>
        """
    end
end

function html(info::Info)
    join(map(html, info.project), "\n")
end

info = from_toml(Info, "packages.toml")::Info

index = """
<!DOCTYPE html>
<html>
$head
<body class="page">
    <div class="page-container">
        $intro
        $(html(info))
    </div>
    <div class="container footer-container">
        罗秀哲 Xiu-Zhe(Roger) Luo - <a href="mailto:me@rogerluo.dev" target="_blank">me@rogerluo.dev</a> &nbsp;- References on request
    </div>
    $theme_script
</body>
</html>
"""

ispath("page") || mkpath("page")
cp("assets", joinpath("page", "assets"))

open(joinpath("page", "index.html"), "w+") do io
    write(io, index)
end
