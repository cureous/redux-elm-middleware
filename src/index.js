export const ELM = '@@elm'

const createElmMiddleware = (elm) => {
  const elmMiddleware = ({dispatch}) => next => action => {
      if (elm.ports && elm.ports[action.type])
        elm.ports[action.type].send(action.payload || null)
      next(action)
    }
  const run = store => {
    window.__REDUX_ELM_STORE__ = store;
  }


  return { elmMiddleware, run }
}

export default createElmMiddleware

export const reducer = function(state = {}, action) {
  const [elmAction, type] = action.type.split('/')
  if (elmAction === ELM) {
    return action.payload
  }

  return state
}
