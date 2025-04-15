import axios from 'axios';

const state = {
  books: [],
  loading: false,
  error: null
};

const mutations = {
  SET_BOOKS(state, books) {
    state.books = books;
  },
  SET_LOADING(state, loading) {
    state.loading = loading;
  },
  SET_ERROR(state, error) {
    state.error = error;
  }
};

const actions = {
  async fetchBooks({ commit }) {
    commit('SET_LOADING', true);
    try {
      const response = await axios.get('/api/books');
      commit('SET_BOOKS', response.data);
      commit('SET_ERROR', null);
    } catch (error) {
      commit('SET_ERROR', error.message);
    } finally {
      commit('SET_LOADING', false);
    }
  },

  async searchBooks({ commit }, query) {
    commit('SET_LOADING', true);
    try {
      const response = await axios.get('/api/books/search', { params: { q: query } });
      commit('SET_BOOKS', response.data);
      commit('SET_ERROR', null);
    } catch (error) {
      commit('SET_ERROR', error.message);
    } finally {
      commit('SET_LOADING', false);
    }
  }
};

const getters = {
  availableBooks: state => state.books.filter(book => book.status === 'available'),
  lentBooks: state => state.books.filter(book => book.status === 'lent')
};

export default {
  namespaced: true,
  state,
  mutations,
  actions,
  getters
}; 