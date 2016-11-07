Resource: Shader water refract test 2.1 v0.1.0
Author: Ren712

changes:
-The refraction is now sky-colored
-Applied some of the code from watershine
-Replaced a noise texture with the watershine one
-Added a fallback water shader (if depthbuffer not supported)
-You can switch on and off the effect typing /sWaterRefract
-/dxGetStatus for error reporting
-Added version check (due to current MTA bugfix)


This resource's main purpose is to test depth buffer. If you see any
artifacts, reduced draw distance etc. - type /dxGetStatus in chatbox.
Then minimise MTA and paste (ctrl+v) into the comments section along
with a short description and maybe a screenshot.

You might turn off antialiasing in case of artifacts - or switch off
the effect with /sWaterRefract command.

----------
This shader uses some vertex and pixel calculations from water_shader by Ccw.
http://wiki.multitheftauto.com/wiki/Shader_examples
Unlike previous water refract shader it uses depth texture image for refraction 
instead of screensource.

It doesn't look as nice as previous 'Shader water refract test' but it works properly.

It might not work on some older GFX (especially INTEL).
It is due to Zbuffer usage.

-- Reading depth buffer supported by:
-- NVidia - from GeForce 6 (2004)
-- Radeon - from 9500 (2002)
-- Intel - from G45 (2008)


