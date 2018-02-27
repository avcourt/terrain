# Terrain Shader



This terrain project has 3 main components: The terrain generation itself, which uses a 2-d noise generating algorithm (found at http://shadertoy.wikia.com/wiki/Noise), ray casting to determine what the camera is seeing (only three materials,: rock, sky, ice) and some way to light it up all up, and finally the camera itself. There’s no way to see all your procedurally generated terrain if the camera doesn’t move anywhere, so I programmed a very basic camera fly-over effect by simply moving the camera position along the Z-axis.

For simplicity I considered only three “materials”, the rocks of the terrain, ice/snow/water or whatever you’d like to call it (I settled on ‘ICE’ as the variable names in GLSL) filling the low spots of the terrain, and “sky” for everything else. Height was considered the distance above(and below, using a range) 0 in the y axis. Once the noise was generated by the noise algorithm, rays were cast from the camera position to determine where the terrain was. Any position that a ray did not intersect (a max distance was also used to limit ray distance) was considered sky. The actual mapping of colour was done by casting rays and returning the height of the intersected ray. With these height values adding in the ice would be easy. Anything within a certain Y-value was coloured as ice, anything outside (that a ray intersected) as rock, and anything else remaining must be sky, and was coloured accordingly.

## Lighting
I used a simple ambient lighting that varied slightly in the range [0-1] based on the calculated normal. For the diffuse light I took the dot product of the surface normal and the light position vector. One of the simplest reflection models out there. This very simple lighting equation does have some drawbacks however; the light value does not vary with the distance from the camera. (Inverse square law!). To fix this problem I used the classic fog effect hack to smooth out the appearance of distance surfaces. (More about this in the does have the added benefit of creating a realistic shadow effect however. With this being the case, I did not worry about implementing any sort of shadow casting, as there are no real “obects” to cast any shadows on the terrain surface anyway. I constrained the normals using OpenGL.clamp incase my equations didn’t properly contrain the values on their own. I did’t notice a change without clamp, but decided to get the constraints incase experimenting with the constants at the top of the program caused different behaviour.

## Fog
To make the brightness of distant terrain look more natural, I decided to take the edge off far away mountains by adding some fog to the scene. I opted for a uniform fog.  I found a great explanation here.

Overall, with only 3 distinct materials I’m quite pleased by the final effect. Certainly more material ranges could be added (for example green trees, water instead of snow, perhaps snow on the tops of mountains, simulating the sun by have a brighter section of the sky) quite easily by creating a few more material IDs and mapping to different their  ranges. Perhaps using the terrain/noise function with different weights/values could be used to simulate trees, or rolling hills.
