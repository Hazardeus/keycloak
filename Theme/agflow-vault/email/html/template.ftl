<#macro emailLayout kicker headline body buttonLabel="" link="" linkExpiration=0 linkExpirationFormatter="" footer="">
<!DOCTYPE html>
<html lang="${locale!'fr'}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <meta name="x-apple-disable-message-reformatting">
    <title>${kicker}</title>
</head>
<body style="margin:0;padding:0;background:#faf9f5;font-family:Georgia,'Times New Roman',Times,serif;color:#0c0e12;-webkit-text-size-adjust:100%;">
<table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="background:#faf9f5;width:100%;">
    <tr>
        <td align="center" style="padding:40px 16px;">

            <table role="presentation" cellpadding="0" cellspacing="0" border="0" width="600" style="width:100%;max-width:600px;background:#faf9f5;">

                <!-- brand -->
                <tr>
                    <td style="padding:0 8px 36px 8px;">
                        <span style="font-family:Georgia,serif;font-size:20px;line-height:1;color:#2353ff;vertical-align:middle;">&#x25C7;</span>
                        <span style="font-family:Georgia,serif;font-size:19px;font-weight:600;letter-spacing:-0.01em;color:#0c0e12;vertical-align:middle;margin-left:8px;">agflow</span>
                    </td>
                </tr>

                <!-- card -->
                <tr>
                    <td style="background:#faf9f5;border:1px solid rgba(12,14,18,0.16);padding:36px 32px;">

                        <p style="margin:0 0 18px 0;font-family:'Courier New',Courier,monospace;font-size:11px;line-height:1;letter-spacing:0.16em;text-transform:uppercase;color:#2353ff;">
                            ${kicker}
                        </p>

                        <h1 style="margin:0 0 18px 0;font-family:Georgia,'Times New Roman',serif;font-weight:400;font-size:30px;line-height:1.12;letter-spacing:-0.022em;color:#0c0e12;">
                            ${headline}
                        </h1>

                        <div style="margin:0 0 28px 0;font-family:Georgia,serif;font-size:16px;line-height:1.6;color:#2a2d34;">
                            ${body}
                        </div>

                        <#if buttonLabel?has_content && link?has_content>
                            <table role="presentation" cellpadding="0" cellspacing="0" border="0">
                                <tr><td bgcolor="#2353ff" style="background:#2353ff;border:1px solid #2353ff;">
                                    <a href="${link}" style="display:inline-block;padding:14px 26px;font-family:Georgia,serif;font-size:16px;font-weight:500;line-height:1;letter-spacing:-0.005em;color:#faf9f5;text-decoration:none;">
                                        ${buttonLabel}&nbsp;&rarr;
                                    </a>
                                </td></tr>
                            </table>

                            <p style="margin:24px 0 0 0;font-family:'Courier New',Courier,monospace;font-size:11.5px;line-height:1.55;color:rgba(12,14,18,0.52);word-break:break-all;">
                                Si le bouton ne s'ouvre pas, copiez ce&nbsp;lien&nbsp;:<br>
                                <a href="${link}" style="color:#2353ff;text-decoration:none;">${link}</a>
                            </p>

                            <#if linkExpiration?? && linkExpiration gt 0 && linkExpirationFormatter?has_content>
                                <p style="margin:18px 0 0 0;padding-top:18px;border-top:1px solid rgba(12,14,18,0.10);font-family:Georgia,serif;font-size:14px;line-height:1.5;color:rgba(12,14,18,0.62);">
                                    Ce lien expire dans <strong style="color:#0c0e12;">${linkExpirationFormatter}</strong>.
                                </p>
                            </#if>
                        </#if>

                        <#if footer?has_content>
                            <p style="margin:24px 0 0 0;padding-top:18px;border-top:1px solid rgba(12,14,18,0.10);font-family:Georgia,serif;font-size:13.5px;line-height:1.55;color:rgba(12,14,18,0.62);font-style:italic;">
                                ${footer}
                            </p>
                        </#if>
                    </td>
                </tr>

                <!-- footer -->
                <tr>
                    <td style="padding:24px 8px 0 8px;font-family:'Courier New',Courier,monospace;font-size:10.5px;line-height:1.4;letter-spacing:0.10em;text-transform:uppercase;color:rgba(12,14,18,0.42);">
                        &copy; ${.now?string("yyyy")} agflow &middot; ${realmName!'le maillage opéré'}
                    </td>
                </tr>
            </table>

        </td>
    </tr>
</table>
</body>
</html>
</#macro>
