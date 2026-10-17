import { Controller } from "@hotwired/stimulus"

// 選んだ画像を、送信前にブラウザで小さな正方形に縮める。
// 通信量と保存容量を抑え、撮影場所などの情報も一緒に消える。
export default class extends Controller {
  static targets = ["input", "preview", "current"]

  resize() {
    const file = this.inputTarget.files[0]
    if (!file || !file.type.startsWith("image/")) return

    const url = URL.createObjectURL(file)
    const img = new Image()
    img.onload = () => {
      const size = 320
      const side = Math.min(img.naturalWidth, img.naturalHeight)
      const sx = (img.naturalWidth - side) / 2
      const sy = (img.naturalHeight - side) / 2
      const canvas = document.createElement("canvas")
      canvas.width = size
      canvas.height = size
      const ctx = canvas.getContext("2d")
      ctx.fillStyle = "#ffffff"
      ctx.fillRect(0, 0, size, size)
      ctx.drawImage(img, sx, sy, side, side, 0, 0, size, size)
      URL.revokeObjectURL(url)

      canvas.toBlob((blob) => {
        if (!blob) return
        const resized = new File([blob], "avatar.jpg", { type: "image/jpeg" })
        const transfer = new DataTransfer()
        transfer.items.add(resized)
        this.inputTarget.files = transfer.files
        this.previewTarget.src = URL.createObjectURL(resized)
        this.previewTarget.hidden = false
        if (this.hasCurrentTarget) this.currentTarget.hidden = true
      }, "image/jpeg", 0.85)
    }
    img.onerror = () => URL.revokeObjectURL(url)
    img.src = url
  }
}
