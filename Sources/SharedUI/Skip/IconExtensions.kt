package skip.ui

import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.ColorFilter
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

/**
 * Load an Android drawable resource by name and display as an Image.
 */
@Composable
fun DrawableImage(
    name: String,
    modifier: Modifier = Modifier,
    tintColor: skip.ui.Color? = null
) {
    val context = skip.foundation.ProcessInfo.processInfo.androidContext
    val resourceId = context.resources.getIdentifier(name, "drawable", context.packageName)

    if (resourceId != 0) {
        val p = painterResource(resourceId)
        val cf = if (tintColor != null) ColorFilter.tint(tintColor.asComposeColor()) else null
        Image(
            painter = p,
            contentDescription = null,
            modifier = modifier,
            colorFilter = cf
        )
    }
}

/**
 * Load a drawable icon with a specific size in dp.
 */
@Composable
fun DrawableIcon(
    name: String,
    sizeDp: Int,
    tintColor: skip.ui.Color? = null
) {
    val context = skip.foundation.ProcessInfo.processInfo.androidContext
    val resourceId = context.resources.getIdentifier(name, "drawable", context.packageName)

    if (resourceId != 0) {
        val p = painterResource(resourceId)
        val cf = if (tintColor != null) ColorFilter.tint(tintColor.asComposeColor()) else null
        val sz: Dp = sizeDp.dp
        Image(
            painter = p,
            contentDescription = null,
            modifier = Modifier.size(sz),
            colorFilter = cf
        )
    }
}
