import UIKit

extension UIImage {
    /// Meng-crop gambar ke bentuk persegi (center crop) dan menggambarnya ulang
    /// tegak lurus. Dipakai supaya koordinat bounding box normalized dari Vision
    /// bisa langsung dipetakan 1:1 ke frame persegi yang ditampilkan di UI,
    /// tanpa perlu hitungan letterbox/aspect-fit tambahan.
    func centerCroppedSquare() -> UIImage {
        let shortSide = min(size.width, size.height)
        let cropOrigin = CGPoint(
            x: (size.width - shortSide) / 2,
            y: (size.height - shortSide) / 2
        )

        UIGraphicsBeginImageContextWithOptions(CGSize(width: shortSide, height: shortSide), false, 1.0)
        draw(at: CGPoint(x: -cropOrigin.x, y: -cropOrigin.y))
        let result = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()
        return result
    }
}
