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
    <link rel="stylesheet" href="/assets/main.css">
    <link rel="shortcut icon" type="image/x-icon" href="images/favicon.jpeg">
    <script src="https://kit.fontawesome.com/0d64c2ab8c.js"></script>
</head>
"""

intro = """
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

    // if (is_night()) {
    //     toggle_theme('dark');
    // } else {
    //     toggle_theme('light');
    // }
    toggle_theme('light');
</script>
"""

@option struct Package
    name::String
    description::String
end

@option struct Project
    name::String
    description::String
    packages::Maybe{Vector{Package}} = nothing
end

@option struct Info
    project::Vector{Project}
end

function html(pkg::Package)
    """
    <li>
        <div class="pkg-name">$(pkg.name)</div>
        <div class="pkg-desc">$(pkg.description)</div>
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

    if isnothing(project.packages)
        """
        <div class="project">
            $name
            $description
        </div>
        """
    else
        packages = join([html(each) for each in project.packages], "\n")
        """
        <div class="project">
            $name
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
    <div class="container">
        $intro
        $(html(info))
    </div>
    $theme_script
</body>
</html>
"""

ispath("page") || mkpath("page")
cp("assets", joinpath("page", "assets"))
open("page/index.html", "w+") do io
    write(io, index)
end
