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
    this.filterInputTargets.forEach(input => input.style.display = 'none')
  }
  toggleForm() {
    this.filterFormContainerTarget.style.display =
      this.filterFormContainerTarget.style.display === "none" ? "block" : "none";
  }
  updateInputs() {
    const selectedFilter = this.filterTypeSelectTarget.value
    this.filterInputTargets.forEach(input => {
      input.style.display = input.dataset.filter === selectedFilter ? 'block' : 'none';
      if (selectedFilter === 'contracted'){
        input.attributes.value = false
      }
    })
    this.filterInputsTarget.style.display =
      selectedFilter === 'all' ? 'none' : 'block';
  }
}
