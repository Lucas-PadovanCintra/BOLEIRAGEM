import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { notificationIds: Array }

  connect() {
    // Show modal automatically when controller connects
    this.showModal()
  }

  showModal() {
    // Get the modal element
    const modalElement = document.getElementById('matchResultsModal')
    if (!modalElement) return

    // Create Bootstrap modal instance
    const modal = new bootstrap.Modal(modalElement, {
      backdrop: 'static',
      keyboard: false
    })

    // Show the modal
    modal.show()

    // Add event listener for when modal is hidden
    modalElement.addEventListener('hidden.bs.modal', () => {
      this.markNotificationsAsViewed()
    }, { once: true })
  }

  markNotificationsAsViewed() {
    // Only mark as viewed if we have notification IDs
    if (!this.notificationIdsValue || this.notificationIdsValue.length === 0) return

    // Get CSRF token
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content

    // Send request to mark notifications as viewed
    fetch('/mark_notifications_viewed', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken
      },
      body: JSON.stringify({
        notification_ids: this.notificationIdsValue
      })
    })
    .then(response => {
      if (response.ok) {
        console.log('Notifications marked as viewed')
      } else {
        console.error('Failed to mark notifications as viewed')
      }
    })
    .catch(error => {
      console.error('Error marking notifications as viewed:', error)
    })
  }
}