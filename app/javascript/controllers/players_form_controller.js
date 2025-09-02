import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="players-form"
export default class extends Controller {
  static targets = [
    'filterButton',
    'filterFormContainer',
    'filterTypeSelect',
    'filterInputs',
    'filterInput'
  ]

  connect() {
    this.filterInputTargets.forEach(input => input.style.display = 'none');
  }

  toggleForm() {
    this.filterFormContainerTarget.style.display =
      this.filterFormContainerTarget.style.display === "none" ? "block" : "none";
  }

  updateInputs() {
    const selectedFilter = this.filterTypeSelectTarget.value;

    // Limpar todos os inputs primeiro
    this.filterInputTargets.forEach(input => {
      const inputField = input.querySelector("input");
      if (inputField) {
        inputField.value = ""; // Reseta o valor do input
      }
      input.style.display = 'none'; // Esconde todos os inputs
    });

    // Configurar o input relevante com base no filter_type
    if (selectedFilter === 'all') {
      // Não precisa de input visível
      this.filterInputsTarget.style.display = 'none';
    } else if (selectedFilter === 'available') {
      const availableInput = this.filterInputTargets.find(el => el.dataset.filter === 'available');
      if (availableInput) {
        availableInput.querySelector("input").value = "true";
        availableInput.style.display = 'block';
      }
      this.filterInputsTarget.style.display = 'block';
    } else if (selectedFilter === 'contracted') {
      const contractedInput = this.filterInputTargets.find(el => el.dataset.filter === 'contracted');
      if (contractedInput) {
        contractedInput.querySelector("input").value = "false";
        contractedInput.style.display = 'block';
      }
      this.filterInputsTarget.style.display = 'block';
    } else {
      // Para name, real_team_name, position, rating, price
      const specificInput = this.filterInputTargets.find(el => el.dataset.filter === selectedFilter);
      if (specificInput) {
        specificInput.style.display = 'block';
      }
      this.filterInputsTarget.style.display = 'block';
    }
  }
}
