<!DOCTYPE html>
<html class="${properties.kcHtmlClass!}" lang="${locale.currentLanguageTag!'fr'}">
<head>
    <meta charset="utf-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="robots" content="noindex, nofollow">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <meta name="theme-color" content="#060914">
    <title>${msg("loginTitle",(realm.displayName!''))}</title>

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="stylesheet"
          href="https://fonts.googleapis.com/css2?family=Bodoni+Moda:ital,opsz,wght@0,6..96,400..900;1,6..96,400..900&family=Geist:wght@300;400;500;600&family=Geist+Mono:wght@300;400;500&display=swap">

    <link rel="stylesheet" href="${url.resourcesPath}/css/styles.css">
</head>
<body class="noct-body">

    <!-- ============================================================
         celestial backdrop · stars, constellation, parallels
         ============================================================ -->
    <div class="celestial" aria-hidden="true">

        <svg class="celestial-stars" viewBox="0 0 1600 1000" preserveAspectRatio="xMidYMid slice">
            <defs>
                <radialGradient id="halo" cx="50%" cy="50%" r="50%">
                    <stop offset="0%" stop-color="#f4b740" stop-opacity="0.9"/>
                    <stop offset="60%" stop-color="#f4b740" stop-opacity="0.0"/>
                </radialGradient>
            </defs>
            <!-- random starfield -->
            <g class="starfield">
                <circle cx="80"   cy="120"  r="0.8" />
                <circle cx="220"  cy="80"   r="0.6" />
                <circle cx="340"  cy="180"  r="1.0" class="twinkle"/>
                <circle cx="460"  cy="60"   r="0.5" />
                <circle cx="580"  cy="140"  r="0.7" />
                <circle cx="690"  cy="200"  r="1.2" class="twinkle d1"/>
                <circle cx="820"  cy="90"   r="0.6" />
                <circle cx="940"  cy="160"  r="0.9" />
                <circle cx="1080" cy="100"  r="0.7" />
                <circle cx="1210" cy="200"  r="1.4" class="twinkle d2"/>
                <circle cx="1340" cy="80"   r="0.5" />
                <circle cx="1480" cy="170"  r="0.8" />
                <circle cx="140"  cy="320"  r="0.6" />
                <circle cx="260"  cy="270"  r="0.9" class="twinkle d3"/>
                <circle cx="420"  cy="380"  r="0.7" />
                <circle cx="540"  cy="320"  r="0.5" />
                <circle cx="780"  cy="360"  r="1.1" class="twinkle"/>
                <circle cx="920"  cy="280"  r="0.6" />
                <circle cx="1060" cy="370"  r="0.8" />
                <circle cx="1180" cy="320"  r="0.5" />
                <circle cx="1320" cy="400"  r="0.7" />
                <circle cx="1450" cy="290"  r="0.9" class="twinkle d1"/>
                <circle cx="60"   cy="500"  r="0.6" />
                <circle cx="200"  cy="560"  r="1.3" class="twinkle d2"/>
                <circle cx="380"  cy="520"  r="0.7" />
                <circle cx="500"  cy="600"  r="0.5" />
                <circle cx="650"  cy="540"  r="0.8" />
                <circle cx="780"  cy="620"  r="0.6" />
                <circle cx="910"  cy="500"  r="0.7" />
                <circle cx="1040" cy="580"  r="1.0" class="twinkle"/>
                <circle cx="1180" cy="540"  r="0.6" />
                <circle cx="1300" cy="610"  r="0.8" />
                <circle cx="1430" cy="520"  r="0.5" />
                <circle cx="120"  cy="720"  r="0.7" />
                <circle cx="260"  cy="780"  r="0.6" />
                <circle cx="400"  cy="720"  r="1.2" class="twinkle d3"/>
                <circle cx="540"  cy="820"  r="0.5" />
                <circle cx="680"  cy="750"  r="0.7" />
                <circle cx="820"  cy="820"  r="0.6" />
                <circle cx="960"  cy="760"  r="0.8" />
                <circle cx="1100" cy="820"  r="0.5" />
                <circle cx="1240" cy="750"  r="0.7" />
                <circle cx="1380" cy="800"  r="1.0" class="twinkle d2"/>
                <circle cx="1500" cy="720"  r="0.6" />
                <circle cx="180"  cy="910"  r="0.5" />
                <circle cx="340"  cy="870"  r="0.7" />
                <circle cx="500"  cy="940"  r="0.6" />
                <circle cx="700"  cy="900"  r="0.8" />
                <circle cx="900"  cy="940"  r="0.5" />
                <circle cx="1100" cy="880"  r="0.7" />
                <circle cx="1300" cy="930"  r="0.6" />
                <circle cx="1460" cy="880"  r="0.5" />
            </g>

            <!-- constellation drawing — Lyra-inspired -->
            <g class="constellation" transform="translate(1180, 230)">
                <line x1="0"   y1="0"   x2="60"  y2="-30"/>
                <line x1="60"  y1="-30" x2="120" y2="-10"/>
                <line x1="120" y1="-10" x2="140" y2="40"/>
                <line x1="0"   y1="0"   x2="20"  y2="60"/>
                <line x1="20"  y1="60"  x2="140" y2="40"/>
                <line x1="20"  y1="60"  x2="-30" y2="100"/>
                <circle cx="0"   cy="0"   r="2.2"/>
                <circle cx="60"  cy="-30" r="1.8"/>
                <circle cx="120" cy="-10" r="2.0"/>
                <circle cx="140" cy="40"  r="2.6" class="bright"/>
                <circle cx="20"  cy="60"  r="1.6"/>
                <circle cx="-30" cy="100" r="1.4"/>
            </g>

            <!-- parallels of latitude — three dotted curves -->
            <g class="parallels">
                <path d="M -50 280 Q 800 250 1650 280" />
                <path d="M -50 500 Q 800 480 1650 500" />
                <path d="M -50 760 Q 800 740 1650 760" />
            </g>
        </svg>

        <div class="celestial-vignette"></div>
        <div class="celestial-grain"></div>
    </div>

    <!-- ============================================================
         top bar · brand sigil + live coordinates
         ============================================================ -->
    <header class="noct-top" role="banner">
        <div class="brand">
            <svg class="brand-sigil" viewBox="0 0 32 32" aria-hidden="true">
                <circle cx="16" cy="16" r="13" />
                <circle cx="16" cy="16" r="7"  class="thin"/>
                <line x1="16" y1="1"  x2="16" y2="6"  />
                <line x1="16" y1="26" x2="16" y2="31" />
                <line x1="1"  y1="16" x2="6"  y2="16" />
                <line x1="26" y1="16" x2="31" y2="16" />
                <circle cx="16" cy="16" r="1.4" class="dot"/>
                <path d="M 16 4 L 18 8 L 14 8 Z" class="north"/>
            </svg>
            <span class="brand-mark">agflow</span>
            <span class="brand-sep">·</span>
            <span class="brand-sub"><em>observatoire</em></span>
        </div>

        <div class="coords" aria-hidden="true">
            <span class="coord">lat. 48°51′24″ <b>N</b></span>
            <span class="coord-sep">·</span>
            <span class="coord">lon. 02°21′07″ <b>E</b></span>
            <span class="coord-sep">|</span>
            <span class="coord coord-clock"><i data-clock>--:--:--</i> <small>UTC</small></span>
            <span class="coord-sep">|</span>
            <span class="coord coord-state"><i class="pulse"></i> uplink&nbsp;ouvert</span>
        </div>
    </header>

    <!-- ============================================================
         main stage
         ============================================================ -->
    <main class="noct-stage">

        <!-- large rotating sigil — celestial sextant -->
        <div class="grand-sigil" aria-hidden="true">
            <svg viewBox="0 0 240 240">
                <g class="ring-outer">
                    <circle cx="120" cy="120" r="116" />
                    <!-- tick marks every 15° -->
                    <g class="ticks">
                        <#list 0..23 as i>
                            <#if i % 6 == 0>
                                <line x1="120" y1="6" x2="120" y2="22"
                                      transform="rotate(${i * 15} 120 120)" class="major"/>
                            <#else>
                                <line x1="120" y1="6" x2="120" y2="14"
                                      transform="rotate(${i * 15} 120 120)"/>
                            </#if>
                        </#list>
                    </g>
                </g>
                <g class="ring-mid">
                    <circle cx="120" cy="120" r="90" />
                </g>
                <g class="ring-inner">
                    <circle cx="120" cy="120" r="60" />
                    <line x1="120" y1="60" x2="120" y2="180" />
                    <line x1="60"  y1="120" x2="180" y2="120" />
                </g>
                <g class="meridian">
                    <path d="M 60 120 Q 120 60 180 120" />
                    <path d="M 60 120 Q 120 180 180 120" />
                </g>
                <g class="north-mark">
                    <path d="M 120 32 L 126 50 L 114 50 Z"/>
                </g>
                <g class="dots">
                    <circle cx="120" cy="120" r="3.4" class="core"/>
                    <circle cx="156" cy="92"  r="1.6"/>
                    <circle cx="84"  cy="148" r="1.4"/>
                    <circle cx="148" cy="148" r="1.2"/>
                </g>
            </svg>
        </div>

        <!-- editorial headline -->
        <section class="herald">
            <p class="eyebrow">
                <span class="num">§I</span>
                <span class="dot">◦</span>
                <span class="lbl">Sanctuaire des opérateurs</span>
            </p>

            <h1 class="display">
                <span class="line"><span>L'observatoire</span></span>
                <span class="line"><span><em>s'illumine</em>.</span></span>
            </h1>

            <p class="lede">
                Inscrivez vos coordonnées pour franchir le&nbsp;seuil.
                Chaque sceau est gravé&nbsp;; chaque entrée, consignée à la&nbsp;main.
            </p>
        </section>

        <!-- ============================================================
             cartouche · ornamental engraved card
             ============================================================ -->
        <section class="cartouche" aria-labelledby="kc-form-heading">

            <!-- ornamental corners -->
            <svg class="cart-corner cc-tl" viewBox="0 0 60 60" aria-hidden="true">
                <path d="M 2 32 Q 2 2 32 2 M 12 32 Q 12 12 32 12 M 2 2 L 8 8 M 32 2 L 32 8 M 2 32 L 8 32"/>
                <circle cx="2" cy="2" r="2.2" class="fill"/>
            </svg>
            <svg class="cart-corner cc-tr" viewBox="0 0 60 60" aria-hidden="true">
                <path d="M 58 32 Q 58 2 28 2 M 48 32 Q 48 12 28 12 M 58 2 L 52 8 M 28 2 L 28 8 M 58 32 L 52 32"/>
                <circle cx="58" cy="2" r="2.2" class="fill"/>
            </svg>
            <svg class="cart-corner cc-bl" viewBox="0 0 60 60" aria-hidden="true">
                <path d="M 2 28 Q 2 58 32 58 M 12 28 Q 12 48 32 48 M 2 58 L 8 52 M 32 58 L 32 52 M 2 28 L 8 28"/>
                <circle cx="2" cy="58" r="2.2" class="fill"/>
            </svg>
            <svg class="cart-corner cc-br" viewBox="0 0 60 60" aria-hidden="true">
                <path d="M 58 28 Q 58 58 28 58 M 48 28 Q 48 48 28 48 M 58 58 L 52 52 M 28 58 L 28 52 M 58 28 L 52 28"/>
                <circle cx="58" cy="58" r="2.2" class="fill"/>
            </svg>

            <header class="cart-head">
                <span class="cart-numeral">N<u>o</u>&nbsp;I</span>
                <span class="cart-title">Cahier&nbsp;des&nbsp;accès</span>
                <span class="cart-date"><i data-date>—</i></span>

                <#if realm.internationalizationEnabled && locale.supported?size gt 1>
                    <label class="cart-lang" aria-label="Langue">
                        <select onchange="if(this.value) window.location=this.value">
                            <#list locale.supported as l>
                                <option value="${l.url}" <#if l.languageTag == locale.currentLanguageTag>selected</#if>>
                                    ${l.label}
                                </option>
                            </#list>
                        </select>
                        <span class="cart-lang-glyph" aria-hidden="true">↳</span>
                    </label>
                </#if>
            </header>

            <h2 id="kc-form-heading" class="cart-h2">
                Inscrivez votre <em>sceau</em>.
            </h2>

            <#if message?has_content>
                <div class="alert alert-${message.type}" role="alert">
                    <span class="alert-glyph" aria-hidden="true">!</span>
                    <span class="alert-text">${kcSanitize(message.summary)?no_esc}</span>
                </div>
            </#if>

            <form id="kc-form-login" class="form" action="${url.loginAction}" method="post" novalidate>

                <div class="field">
                    <label for="username">
                        <span class="rom">I.</span>
                        <span class="lbl">
                            <#if !realm.loginWithEmailAllowed>Nom d'opérateur
                            <#elseif !realm.registrationEmailAsUsername>Adresse de correspondance
                            <#else>Courriel ou nom d'opérateur</#if>
                        </span>
                    </label>
                    <input tabindex="1" id="username" class="input" name="username"
                           value="${(login.username!'')}" type="text" autofocus
                           autocomplete="username"
                           spellcheck="false" autocapitalize="off" />
                    <span class="rule" aria-hidden="true"></span>
                </div>

                <div class="field">
                    <label for="password">
                        <span class="rom">II.</span>
                        <span class="lbl">Sceau&nbsp;privé</span>
                    </label>
                    <input tabindex="2" id="password" class="input" name="password"
                           type="password" autocomplete="current-password" />
                    <span class="rule" aria-hidden="true"></span>
                </div>

                <div class="row">
                    <#if realm.rememberMe && !usernameEditDisabled??>
                        <label class="check">
                            <input tabindex="3" id="rememberMe" name="rememberMe" type="checkbox"
                                <#if login.rememberMe??>checked</#if>>
                            <span class="box" aria-hidden="true"></span>
                            <span class="lbl">Maintenir le sceau ouvert</span>
                        </label>
                    <#else>
                        <span></span>
                    </#if>

                    <#if realm.resetPasswordAllowed>
                        <a class="forgot" href="${url.loginResetCredentialsUrl}">
                            Sceau&nbsp;égaré&nbsp;?
                        </a>
                    </#if>
                </div>

                <button tabindex="4" class="ignite" name="login" id="kc-login" type="submit">
                    <span class="ignite-flame" aria-hidden="true"></span>
                    <span class="ignite-rune" aria-hidden="true">✦</span>
                    <span class="ignite-lbl"><em>Allumer</em> le sanctuaire</span>
                    <span class="ignite-arrow" aria-hidden="true">↗</span>
                </button>
            </form>

            <#if realm.password && social.providers?? && social.providers?has_content>
                <div class="federated">
                    <p class="federated-rule">
                        <span class="dash"></span>
                        <span class="lbl">ou&nbsp;·&nbsp;sceaux étrangers</span>
                        <span class="dash"></span>
                    </p>

                    <div id="kc-social-providers" class="federated-grid">
                        <#list social.providers as p>
                            <a class="seal" href="${p.loginUrl}">
                                <span class="seal-mark" aria-hidden="true">◐</span>
                                <span class="seal-name">${p.alias?cap_first}</span>
                                <span class="seal-arrow" aria-hidden="true">→</span>
                            </a>
                        </#list>
                    </div>
                </div>
            </#if>

            <!-- wax seal & engraved serial -->
            <footer class="cart-foot">
                <span class="wax" aria-hidden="true">
                    <span class="wax-drop"></span>
                    <span class="wax-glyph">A·G</span>
                </span>
                <span class="cart-serial">
                    <span>scellé</span>
                    <i data-session>—</i>
                </span>
            </footer>

        </section>

        <!-- credo strip below the cartouche -->
        <ol class="credo" aria-label="Garanties">
            <li>
                <span class="rom">I.</span>
                <span class="lbl">Identité signée, horodatée, révocable.</span>
            </li>
            <li>
                <span class="rom">II.</span>
                <span class="lbl">Chaque accès, gravé au registre.</span>
            </li>
            <li>
                <span class="rom">III.</span>
                <span class="lbl">L'opérateur garde la main.</span>
            </li>
        </ol>

    </main>

    <!-- ============================================================
         bottom bar
         ============================================================ -->
    <footer class="noct-bottom">
        <span class="left">© ${.now?string("yyyy")} · agflow · l'observatoire</span>
        <span class="mark">✦ &nbsp; · &nbsp; ✦ &nbsp; · &nbsp; ✦</span>
        <span class="right">chiffré · oidc · x509</span>
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

        // engraved date in cartouche header, FR style
        var dates = document.querySelectorAll('[data-date]');
        var monthsFR = [
            'janvier','février','mars','avril','mai','juin',
            'juillet','août','septembre','octobre','novembre','décembre'
        ];
        var now = new Date();
        var label = now.getDate() + ' ' + monthsFR[now.getMonth()] + ' ' + now.getFullYear();
        for (var i = 0; i < dates.length; i++) dates[i].textContent = label;

        // engraved session serial
        var sess = document.querySelector('[data-session]');
        if (sess) {
            var s = '';
            var alphabet = '0123456789ABCDEF';
            for (var i = 0; i < 10; i++) s += alphabet[Math.floor(Math.random() * alphabet.length)];
            sess.textContent = s.replace(/(.{2})/g, '$1·').replace(/·$/, '');
        }
    })();
    </script>
</body>
</html>
