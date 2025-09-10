import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    redirectUrl: String
  };

  expire(event) {
    const contractId = event.currentTarget.dataset.contractId;
    if (!confirm("Tem certeza que deseja expirar este contrato? O jogador ficará disponível no mercado.")) {
      return;
    }

    if (!contractId) {
      alert("Erro: ID do contrato não encontrado.");
      return;
    }

    const csrfToken = document.querySelector('meta[name="csrf-token"]').content;

    fetch(`/player_contracts/${contractId}/expire`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken
      }
    })
      .then(response => response.json())
      .then(data => {
        if (data.error) {
          alert(data.error);
        } else {
          alert(data.notice);
          window.location.href = this.redirectUrlValue;
        }
      })
      .catch(error => {
        alert(`Erro ao expirar contrato: ${error.message}`);
      });
  }
}
