import {
  LightningElement,
  api,
  track
} from 'lwc';

export default class PaginationNavigation extends LightningElement {
  currentPage = 1;
  totalRecords;
  recordSize = 10;
  offSet = 0;
  @track visibleRecords;
  @track totalPages = 1;
  @track isNext;
  @track isPrev;

  @api set records(data) {
    if (data && data.length > 0) {
      this.totalRecords = data;
      this.totalPages = Math.ceil(data.length / this.recordSize);
      this.updateRecords();
    }
  }
  get records() {
    return this.visibleRecords;
  }

  handlePrev() {
    if (this.currentPage > 1) {
      this.currentPage -= 1;
      this.updateRecords();
    }
  }

  get disablePrevious() {
    return this.currentPage <= 1;
  }

  get disableNext() {
    return this.currentPage >= this.totalPages;
  }

  handleNext() {
    if (this.currentPage < this.totalPages) {
      this.currentPage += 1;
      this.updateRecords();
    }
  }

  updateRecords() {
    const startIndex = (this.currentPage - 1) * this.recordSize;
    const endIndex = this.recordSize * this.currentPage;
    this.visibleRecords = this.totalRecords.slice(startIndex, endIndex);
    this.dispatchEvent(new CustomEvent('slice', {
      detail: {
        slicedRecords: this.visibleRecords
      }
    }))
  }
}