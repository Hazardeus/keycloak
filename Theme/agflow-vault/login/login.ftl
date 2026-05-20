<!DOCTYPE html>
<html class="${properties.kcHtmlClass!}" lang="${locale.currentLanguageTag!'fr'}">
<head>
    <meta charset="utf-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="robots" content="noindex, nofollow">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>${msg("loginTitle",(realm.displayName!''))}</title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="stylesheet"
          href="https://fonts.googleapis.com/css2?family=Fraunces:ital,opsz,wght@0,9..144,300..800;1,9..144,300..800&family=JetBrains+Mono:wght@400;500&display=swap">

    <link rel="stylesheet" href="${url.resourcesPath}/css/styles.css">
</head>
<body class="v-body">

    <svg class="v-mesh" viewBox="0 0 1600 900" preserveAspectRatio="xMidYMid slice" aria-hidden="true">
        <g class="v-mesh-links">
            <line class="v-link v-link-1" data-from="0" data-to="1" x1="140" y1="180" x2="420" y2="340"/>
            <line class="v-link v-link-2" data-from="1" data-to="2" x1="420" y1="340" x2="220" y2="600"/>
            <line class="v-link v-link-3" data-from="1" data-to="3" x1="420" y1="340" x2="720" y2="260"/>
            <line class="v-link v-link-4" data-from="2" data-to="4" x1="220" y1="600" x2="540" y2="760"/>
            <line class="v-link v-link-5" data-from="4" data-to="5" x1="540" y1="760" x2="160" y2="820"/>
            <line class="v-link v-link-6" data-from="0" data-to="2" x1="140" y1="180" x2="220" y2="600"/>
            <line class="v-link v-link-7" data-from="3" data-to="4" x1="720" y1="260" x2="540" y2="760"/>
            <line class="v-link v-link-8" data-from="3" data-to="6" x1="720" y1="260" x2="980" y2="540"/>
            <line class="v-link v-link-9" data-from="6" data-to="4" x1="980" y1="540" x2="540" y2="760"/>
        </g>
        <g class="v-mesh-nodes">
            <circle class="v-node v-node-1" data-node="0" cx="140" cy="180" r="3"/>
            <circle class="v-node v-node-2" data-node="1" cx="420" cy="340" r="3"/>
            <circle class="v-node v-node-3" data-node="2" cx="220" cy="600" r="3"/>
            <circle class="v-node v-node-4" data-node="3" cx="720" cy="260" r="3"/>
            <circle class="v-node v-node-5" data-node="4" cx="540" cy="760" r="3"/>
            <circle class="v-node v-node-6" data-node="5" cx="160" cy="820" r="3"/>
            <circle class="v-node v-node-7" data-node="6" cx="980" cy="540" r="3"/>
        </g>
    </svg>

    <header class="v-topbar" role="banner">
        <a class="v-brand" href="https://yoops.org" aria-label="agflow">
            <span class="v-brand-mark" aria-hidden="true">◇</span>
            <span class="v-brand-name">agflow</span>
        </a>

        <#if realm.internationalizationEnabled && locale.supported?size gt 1>
            <label class="v-locale" aria-label="Langue">
                <select onchange="if(this.value) window.location=this.value">
                    <#list locale.supported as l>
                        <option value="${l.url}" <#if l.languageTag == locale.currentLanguageTag>selected</#if>>
                            ${l.label}
                        </option>
                    </#list>
                </select>
                <span class="v-locale-glyph" aria-hidden="true">▾</span>
            </label>
        </#if>
    </header>

    <main class="v-stage">

        <section class="v-editorial" aria-labelledby="v-headline">

            <p class="v-eyebrow">Console agflow</p>

            <h1 id="v-headline" class="v-headline">
                <span class="v-line">Vos accès,</span>
                <span class="v-line"><em>signés</em>.</span>
            </h1>

            <p class="v-lede">
                Une seule porte, une empreinte par&nbsp;session.
            </p>

        </section>

        <section class="v-card" aria-labelledby="kc-form-heading">

            <header class="v-card-head">
                <p class="v-card-kicker">connexion</p>
                <h2 id="kc-form-heading" class="v-card-title">
                    Ouvrez votre session.
                </h2>
            </header>

            <#if message?has_content>
                <div class="v-alert v-alert-${message.type}" role="alert">
                    <span class="v-alert-glyph" aria-hidden="true">!</span>
                    <span>${kcSanitize(message.summary)?no_esc}</span>
                </div>
            </#if>

            <form id="kc-form-login" class="v-form" action="${url.loginAction}" method="post" novalidate>

                <div class="v-field">
                    <label for="username">
                        <#if !realm.loginWithEmailAllowed>Nom d'utilisateur
                        <#elseif !realm.registrationEmailAsUsername>Adresse e-mail
                        <#else>Courriel ou nom d'utilisateur</#if>
                    </label>
                    <input tabindex="1" id="username" class="v-input" name="username"
                           value="${(login.username!'')}" type="text" autofocus
                           autocomplete="username"
                           spellcheck="false" autocapitalize="off" />
                    <span class="v-field-rule" aria-hidden="true"></span>
                </div>

                <div class="v-field">
                    <label for="password">${msg("password")}</label>
                    <input tabindex="2" id="password" class="v-input" name="password"
                           type="password" autocomplete="current-password" />
                    <span class="v-field-rule" aria-hidden="true"></span>
                </div>

                <div class="v-field-row">
                    <#if realm.rememberMe && !usernameEditDisabled??>
                        <label class="v-check">
                            <input tabindex="3" id="rememberMe" name="rememberMe" type="checkbox"
                                <#if login.rememberMe??>checked</#if>>
                            <span class="v-check-box" aria-hidden="true"></span>
                            <span class="v-check-lbl">Se souvenir</span>
                        </label>
                    <#else>
                        <span></span>
                    </#if>

                    <#if realm.resetPasswordAllowed>
                        <a class="v-link" href="${url.loginResetCredentialsUrl}">
                            Mot de passe oublié&nbsp;?
                        </a>
                    </#if>
                </div>

                <button tabindex="4" class="v-btn" name="login" id="kc-login" type="submit">
                    <span class="v-btn-label">Se connecter</span>
                    <span class="v-btn-arrow" aria-hidden="true">→</span>
                </button>
            </form>

            <#if realm.password && social.providers?? && social.providers?has_content>
                <div class="v-federated">
                    <p class="v-federated-rule"><span>ou</span></p>

                    <div id="kc-social-providers" class="v-federated-grid">
                        <#list social.providers as p>
                            <a class="v-federated-item" href="${p.loginUrl}">
                                <span class="v-federated-name">${p.alias?cap_first}</span>
                                <span class="v-federated-arrow" aria-hidden="true">→</span>
                            </a>
                        </#list>
                    </div>
                </div>
            </#if>

        </section>

    </main>

    <footer class="v-foot">
        <span>© ${.now?string("yyyy")} agflow</span>
    </footer>

    <script>
    /* mouse spotlight follower */
    (function () {
        var body = document.body;
        var tx = 88, ty = 12, cx = 88, cy = 12;
        var raf = null;

        function tick() {
            cx += (tx - cx) * 0.08;
            cy += (ty - cy) * 0.08;
            body.style.setProperty('--mx', cx.toFixed(2) + '%');
            body.style.setProperty('--my', cy.toFixed(2) + '%');
            if (Math.abs(tx - cx) > 0.05 || Math.abs(ty - cy) > 0.05) {
                raf = requestAnimationFrame(tick);
            } else {
                raf = null;
            }
        }

        window.addEventListener('pointermove', function (e) {
            tx = (e.clientX / window.innerWidth) * 100;
            ty = (e.clientY / window.innerHeight) * 100;
            if (!raf) raf = requestAnimationFrame(tick);
        }, { passive: true });

        window.addEventListener('pointerleave', function () {
            tx = 88; ty = 12;
            if (!raf) raf = requestAnimationFrame(tick);
        });
    })();

    /* mesh — nodes drift on individual orbits, links follow */
    (function () {
        if (window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;

        var nodeEls = document.querySelectorAll('.v-mesh .v-node');
        var linkEls = document.querySelectorAll('.v-mesh .v-link');
        if (!nodeEls.length) return;

        var nodes = [];
        for (var i = 0; i < nodeEls.length; i++) {
            var el = nodeEls[i];
            var x0 = parseFloat(el.getAttribute('cx'));
            var y0 = parseFloat(el.getAttribute('cy'));
            nodes.push({
                el: el,
                x0: x0, y0: y0,
                x: x0, y: y0,
                ax: 18 + (i * 4) % 14,
                ay: 14 + (i * 6) % 16,
                fx: 0.00016 + i * 0.00003,
                fy: 0.00021 + i * 0.00002,
                px: i * 0.83,
                py: i * 1.27
            });
        }

        var links = [];
        for (var j = 0; j < linkEls.length; j++) {
            links.push({
                el: linkEls[j],
                a: parseInt(linkEls[j].getAttribute('data-from'), 10),
                b: parseInt(linkEls[j].getAttribute('data-to'), 10)
            });
        }

        function tick(t) {
            for (var k = 0; k < nodes.length; k++) {
                var n = nodes[k];
                n.x = n.x0 + n.ax * Math.sin(t * n.fx + n.px);
                n.y = n.y0 + n.ay * Math.cos(t * n.fy + n.py);
                n.el.setAttribute('cx', n.x.toFixed(2));
                n.el.setAttribute('cy', n.y.toFixed(2));
            }
            for (var m = 0; m < links.length; m++) {
                var l = links[m];
                var na = nodes[l.a], nb = nodes[l.b];
                l.el.setAttribute('x1', na.x.toFixed(2));
                l.el.setAttribute('y1', na.y.toFixed(2));
                l.el.setAttribute('x2', nb.x.toFixed(2));
                l.el.setAttribute('y2', nb.y.toFixed(2));
            }
            requestAnimationFrame(tick);
        }

        requestAnimationFrame(tick);
    })();
    </script>

</body>
</html>
