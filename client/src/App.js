import React from 'react';
import './App.css';

const DOMAIN = 'localhost:3002'

export function handleAPIResponse (resp) {
    const contentType = resp.headers.get('content-type')
    var isJSON = contentType && contentType.indexOf('application/json') !== -1

    var nextResponse = isJSON ? resp.json() : resp.text()

    return resp.ok ? nextResponse : nextResponse.then(data => Promise.reject(data))
}

function fetchJSON (url, customSettings = {}) {
    let settings = Object.assign(
        {},
        customSettings,
        {
            cache: "no-cache",
            headers: { 'Content-Type': 'application/json' }
        }
    )

    return fetch(url, settings)
        .then(handleAPIResponse)
}

// window.postData = (url = ``, data = {}) => {
//     return fetch(url, {
//         method: "POST",
//         mode: 'no-cors',
//         cache: "no-cache",
//         credentials: 'include',
//         headers: {
//             "Content-Type": "application/json",
//         },
//         // redirect: "error", // manual, *follow, error
//         // referrer: "no-referrer", // no-referrer, *client
//         body: JSON.stringify(data),
//     })
//         .then(response => { window.LAST_RESPONSE = response })
// }

const CellComponent = ({ number, selected, numberToggled, selectionDisabled }) => {
    const classNames = `cell ${selected ? 'selected' : ''}`
    const handleClick = (e) => {
        e.preventDefault()
        numberToggled(number)
    }

    return (
        <button className={classNames}
            key={number}
            disabled={selected ? false : selectionDisabled}
            onClick={handleClick}
        >{number}</button>
    )
}

const TicketComponent = ({ afterTicketSubmit }) => {
    const [nickname, changeNickname] = React.useState('')
    const [selectedNumbers, changeSelectedNumbers] = React.useState([])
    const selectedCount = selectedNumbers.length

    const numberToggled = (number) => {
        if (selectedNumbers.includes(number)) {
            changeSelectedNumbers(selectedNumbers.filter((n) => n !== number))
        } else {
            changeSelectedNumbers([number, ...selectedNumbers])
        }
    }
    const handleNicknameChange = (e) => { changeNickname(e.target.value) }
    const handleSubmit = () => {
        debugger
        fetchJSON(`http://${DOMAIN}/lottery/tickets`, {
            method: 'POST',
            body: JSON.stringify({ ticket: { nickname, numbers: selectedNumbers } })
        }).then((_data) => afterTicketSubmit())
    }

    return (
        <div className="Ticket">
            <form onSubmit={handleSubmit}>
                <input type="text" value={nickname} placeholder="Nickname" onChange={handleNicknameChange} />
                <div className="Ticket-cells">
                    {
                        [...Array(49).keys()].map((i) =>
                            CellComponent({
                                numberToggled,
                                number: i + 1,
                                selected: selectedNumbers.includes(i + 1),
                                selectionDisabled: selectedCount === 6,
                            })
                        )
                    }
                </div>
                <button className="button" disabled={selectedCount !== 6 || !nickname}>Enroll</button>
                <p>{selectedCount}/6 selected</p>
            </form>
        </div>
    )
}

const WinnersTableComponent = ({ winningTickets }) => {
    const sortedTickets = winningTickets.sort((first, second) => second.matches_count - first.matches_count)
    const WinningRow = ({ ticket: { nickname, prize, matches_count } }) => {
        return (
            <li className="WinnersTable-row" >
                <span>{nickname}</span> just won {prize} {matches_count === 6 ? '🎉' : null}
            </li>
        )
    }

    return (
        <ul className="WinnersTable">
            {sortedTickets.map((ticket, i) => (<WinningRow ticket={ticket} key={i} />))}
        </ul>
    )
}

const App = () => {
    const [menuActivity, setMenuActivity] = React.useState({ enrollPage: true })
    const [winningTickets, changeWinningTickets] = React.useState(null)
    const [ticketsCount, changeTicketsCount] = React.useState(null);

    const syncTicketsCount = () => {
        fetchJSON(`http://${DOMAIN}/lottery/tickets`)
            .then(({ tickets_count }) => { changeTicketsCount(tickets_count) })
    }
    const handleDrawClick = () => {
        fetchJSON(`http://${DOMAIN}/lottery/draws`, { method: 'POST' })
            .then(({ tickets }) => {
                changeWinningTickets(tickets)
                setMenuActivity({ resultsPage: true })
            })
    }

    if (!ticketsCount) {
        syncTicketsCount()
        return (<div> Loading... </div>)
    }

    const enrollPageClasses = `Menu-item ${menuActivity.enrollPage ? 'active' : ''}`
    const drawPageClasses = `Menu-item ${menuActivity.drawPage ? 'active' : ''}`
    const resultsPageClasses = `Menu-item ${menuActivity.resultsPage ? 'active' : ''}`

    let mainBodyContent
    if (menuActivity.enrollPage) {
        mainBodyContent = (<TicketComponent afterTicketSubmit={() => { setMenuActivity({ enrollPage: false, drawPage: true }) }} />)
    } else if (menuActivity.drawPage) {
        syncTicketsCount()
        mainBodyContent = (
            <div className='DrawPage'>
                <span><strong>{ticketsCount}</strong> tickets submited</span>
                <button className="button" onClick={handleDrawClick}> Find the winner </button>
            </div>
        )
    } else if (menuActivity.resultsPage) {
        mainBodyContent = winningTickets ?
            (<WinnersTableComponent winningTickets={winningTickets} />)
            :
            (<div> No results yet </div>)
    }

    return (
        <div className="App">
            <div className="App-header">
                <h1>Lottery 6/49</h1>
            </div>
            <div className="App-body">
                <div className="Menu">
                    <span onMouseOver={() => { setMenuActivity({ enrollPage: true }) }} className={enrollPageClasses}>
                        <span>Play now</span>
                    </span>
                    <span onMouseOver={() => { setMenuActivity({ drawPage: true }) }} className={drawPageClasses}>
                        <span>Draw!</span>
                    </span>
                    <span onMouseOver={() => { setMenuActivity({ resultsPage: true }) }} className={resultsPageClasses}>
                        <span>See results</span>
                    </span>
                </div>
                <div className="App-body-main">
                    {mainBodyContent}
                </div>
            </div>
        </div>
    )
}

// const App = () => {
//     const [winningTickets, changeWinningTickets] = React.useState(null)
//     // const [winningTickets, changeWinningTickets] = React.useState([
//     //     { nickname: 'pesho', matches_count: 3, prize: 100 },
//     //     { nickname: 'gosho', matches_count: 3, prize: 100 },
//     //     { nickname: 'maria33', matches_count: 3, prize: 100 },
//     //     { nickname: 'papa jan', matches_count: 4, prize: 300 },
//     //     { nickname: 'victor', matches_count: 4, prize: 300 },
//     //     { nickname: 'Resjoo', matches_count: 5, prize: 10000 },
//     //     { nickname: 'papa jan', matches_count: 6, prize: 1000000 }
//     // ])
//     // fetch('localhost:3002/lottery').then(({ id }) => { updateLotteryId(id) })

//     // if (!lotteryId) {
//     //     return (
//     //         <div>Loading...</div>
//     //     )
//     // }
//     const drawLottery = () => {
//         fetchJSON(`http://${DOMAIN}/lottery/draws`, { method: 'POST' })
//             .then((tickets) => changeWinningTickets(tickets))
//     }

//     const activeSubPage = 'ticket'
//     const ticketClasses = `TicketSide SubPage ${activeSubPage === 'ticket' ? 'ActiveSubPage' : ''}`
//     const drawClasses = `DrawSide SubPage ${activeSubPage === 'draw' ? 'ActiveSubPage' : ''}`
//     const resultsClasses = `ResultsSide SubPage ${activeSubPage === 'results' ? 'ActiveSubPage' : ''}`

//     return (
//         <div className="App">
//             <div className="App-header">
//                 <h1>Lottery 6/49</h1>
//             </div>
//             <div className="App-body">
//                 {
//                     winningTickets ?
//                         (<WinnersTableComponent winningTickets={winningTickets} />)
//                         :
//                         [
//                             <div className={ticketClasses}>
//                                 <TicketComponent />
//                             </div>,
//                             <div className={drawClasses}>
//                                 <button className="button big-red" onClick={drawLottery}> Find the winner </button>
//                             </div>,
//                             <div className={resultsClasses}></div>
//                         ]
//                 }
//             </div>
//         </div>
//     );
// }

export default App;
