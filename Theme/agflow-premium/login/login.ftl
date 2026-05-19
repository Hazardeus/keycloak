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
          href="https://fonts.googleapis.com/css2?family=Fraunces:ital,opsz,wght@0,9..144,300..800;1,9..144,300..800&family=JetBrains+Mono:wght@300;400;500;600&display=swap">

    <link rel="stylesheet" href="${url.resourcesPath}/css/styles.css">
</head>
<body class="agflow-body">

    <svg class="agflow-grain" aria-hidden="true">
        <filter id="agflow-noise">
            <feTurbulence type="fractalNoise" baseFrequency="0.9" numOctaves="2" stitchTiles="stitch"/>
            <feColorMatrix values="0 0 0 0 0  0 0 0 0 0  0 0 0 0 0  0 0 0 0.32 0"/>
        </filter>
        <rect width="100%" height="100%" filter="url(#agflow-noise)"/>
    </svg>

    <header class="agflow-statusbar" role="banner">
        <span class="sb-cell sb-mark">◇ agflow · auth-gateway</span>
        <span class="sb-cell sb-host">auth.yoops.org</span>
        <span class="sb-cell sb-meta">tls : cloudflare · keycloak : 26.x</span>
        <span class="sb-cell sb-clock"><i data-clock>--:--:--</i> UTC</span>
        <span class="sb-cell sb-state"><i class="dot"></i> uplink ok</span>
    </header>

    <main class="agflow-stage">

        <section class="manifest" aria-labelledby="agflow-headline">
            <p class="manifest-eyebrow">
                <span>Portail d'accès</span>
                <span class="dash">—</span>
                <span>§01&nbsp;/&nbsp;03</span>
            </p>

            <h1 id="agflow-headline" class="manifest-headline">
                <span class="line">L'orchestrateur</span>
                <span class="line"><em>s'éveille</em>.</span>
                <span class="line caret">Identifiez-vous<span class="cursor"></span></span>
            </h1>

            <p class="manifest-lede">
                Chaque agent rejoint le maillage sous identité signée
                et&nbsp;horodatée. Rien ne franchit cette&nbsp;ligne
                sans une&nbsp;empreinte vérifiée.
            </p>

            <ol class="manifest-index" aria-label="Sommaire du portail">
                <li>
                    <span class="idx">§01</span>
                    <span class="lbl">Identité signée, horodatée, révocable.</span>
                </li>
                <li>
                    <span class="idx">§02</span>
                    <span class="lbl">Workflows tracés de bout en bout.</span>
                </li>
                <li>
                    <span class="idx">§03</span>
                    <span class="lbl">Opérateurs jamais hors de la boucle.</span>
                </li>
            </ol>

            <pre class="manifest-diagram" aria-hidden="true">
   you ──┐
         ├──▶ [ keycloak ]──┬──▶ workflows
   sso ──┘                   └──▶ audit log
            </pre>
        </section>

        <section class="terminal" aria-labelledby="kc-form-heading">
            <div class="terminal-frame">

                <div class="terminal-tabs">
                    <span class="tab tab-on">access&nbsp;·&nbsp;<i data-clock>--:--:--</i>z</span>
                    <span class="tab">policy</span>
                    <span class="tab">audit</span>

                    <#if realm.internationalizationEnabled && locale.supported?size gt 1>
                        <label class="locale" aria-label="Langue">
                            <select onchange="if(this.value) window.location=this.value">
                                <#list locale.supported as l>
                                    <option value="${l.url}" <#if l.languageTag == locale.currentLanguageTag>selected</#if>>
                                        ${l.label}
                                    </option>
                                </#list>
                            </select>
                            <span class="locale-glyph" aria-hidden="true">↳</span>
                        </label>
                    </#if>
                </div>

                <div class="terminal-body">

                    <header class="terminal-head">
                        <p class="kicker">↳ access&nbsp;terminal</p>
                        <h2 id="kc-form-heading">
                            Connectez-vous<br>
                            au <em>maillage</em>.
                        </h2>
                        <p class="sub">
                            Saisissez vos identifiants pour ouvrir
                            une&nbsp;session opérateur.
                        </p>
                    </header>

                    <#if message?has_content>
                        <div class="alert alert-${message.type}" role="alert">
                            <span class="alert-glyph" aria-hidden="true">!</span>
                            <span>${kcSanitize(message.summary)?no_esc}</span>
                        </div>
                    </#if>

                    <form id="kc-form-login" class="login-form" action="${url.loginAction}" method="post" novalidate>

                        <div class="field">
                            <label for="username">
                                <span class="field-num">01</span>
                                <span class="field-text">
                                    <#if !realm.loginWithEmailAllowed>Nom d'utilisateur
                                    <#elseif !realm.registrationEmailAsUsername>Adresse e-mail
                                    <#else>Courriel ou nom d'utilisateur</#if>
                                </span>
                            </label>
                            <input tabindex="1" id="username" class="input" name="username"
                                   value="${(login.username!'')}" type="text" autofocus
                                   autocomplete="username"
                                   spellcheck="false" autocapitalize="off" />
                            <span class="field-rule" aria-hidden="true"></span>
                        </div>

                        <div class="field">
                            <label for="password">
                                <span class="field-num">02</span>
                                <span class="field-text">${msg("password")}</span>
                            </label>
                            <input tabindex="2" id="password" class="input" name="password"
                                   type="password" autocomplete="current-password" />
                            <span class="field-rule" aria-hidden="true"></span>
                        </div>

                        <div class="field-row">
                            <#if realm.rememberMe && !usernameEditDisabled??>
                                <label class="checkbox">
                                    <input tabindex="3" id="rememberMe" name="rememberMe" type="checkbox"
                                        <#if login.rememberMe??>checked</#if>>
                                    <span class="box" aria-hidden="true"></span>
                                    <span class="lbl">Garder cette session ouverte</span>
                                </label>
                            <#else>
                                <span></span>
                            </#if>

                            <#if realm.resetPasswordAllowed>
                                <a class="link-dotted" href="${url.loginResetCredentialsUrl}">
                                    Mot de passe oublié&nbsp;?
                                </a>
                            </#if>
                        </div>

                        <button tabindex="4" class="btn-signal" name="login" id="kc-login" type="submit">
                            <span class="btn-label">Ouvrir la session</span>
                            <span class="btn-mono" aria-hidden="true">[ enter&nbsp;↵ ]</span>
                            <span class="btn-arrow" aria-hidden="true">→</span>
                        </button>
                    </form>

                    <#if realm.password && social.providers?? && social.providers?has_content>
                        <div class="federated">
                            <p class="federated-rule">
                                <span>or · federated identities</span>
                            </p>

                            <div id="kc-social-providers" class="federated-grid">
                                <#list social.providers as p>
                                    <a class="federated-ticket" href="${p.loginUrl}">
                                        <span class="t-glyph" aria-hidden="true">◐</span>
                                        <span class="t-name">${p.alias?cap_first}</span>
                                        <span class="t-arrow" aria-hidden="true">→</span>
                                    </a>
                                </#list>
                            </div>
                        </div>
                    </#if>

                </div>
            </div>

            <div class="terminal-stamp" aria-hidden="true">
                <span>signed</span>
                <span>·</span>
                <span>x509</span>
                <span>·</span>
                <span>oidc</span>
                <span>·</span>
                <span>${.now?string("yyyy")}</span>
            </div>
        </section>

    </main>

    <footer class="agflow-foot">
        <span>© ${.now?string("yyyy")} · agflow · le maillage opéré.</span>
        <span class="foot-ascii">⌁ ⌁ ⌁</span>
        <span>session : <i data-session>—</i></span>
    </footer>

    <script>
    (function () {
        var pad = function (n) { return (n < 10 ? '0' : '') + n; };
        var clocks = document.querySelectorAll('[data-clock]');
        function tick() {
            var d = new Date();
            var t = pad(d.getUTCHours()) + ':' + pad(d.getUTCMinutes()) + ':' + pad(d.getUTCSeconds());
            for (var i = 0; i < clocks.length; i++) clocks[i].textContent = t;
        }
        tick();
        setInterval(tick, 1000);

        var sess = document.querySelector('[data-session]');
        if (sess) {
            var s = '';
            var alphabet = '0123456789abcdef';
            for (var i = 0; i < 12; i++) s += alphabet[Math.floor(Math.random() * alphabet.length)];
            sess.textContent = s.replace(/(.{4})/g, '$1·').replace(/·$/, '');
        }
    })();
    </script>
</body>
</html>
